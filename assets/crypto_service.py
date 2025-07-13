#!/usr/bin/env python3
"""
Invictus Trader Pro - Módulo Python para Criptomonedas
Sistema completo de obtención y análisis de precios de criptomonedas
Incluye WebSocket en tiempo real, APIs REST, análisis técnico y más.
"""

import json
import time
import threading
import asyncio
import requests
import websocket
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Callable
import logging
from dataclasses import dataclass, asdict
import sqlite3
import os

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class CryptoPrice:
    symbol: str
    price: float
    change_24h: float
    change_percent_24h: float
    volume_24h: float
    high_24h: Optional[float] = None
    low_24h: Optional[float] = None
    market_cap: Optional[float] = None
    market_cap_rank: Optional[int] = None
    timestamp: float = None
    source: str = "Python"
    
    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = time.time()
    
    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)
    
    def to_json(self) -> str:
        return json.dumps(self.to_dict())

class CryptoPriceDatabase:
    """Base de datos SQLite para almacenar precios históricos"""
    
    def __init__(self, db_path: str = "crypto_prices.db"):
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        """Inicializar base de datos"""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute('''
                CREATE TABLE IF NOT EXISTS prices (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    symbol TEXT NOT NULL,
                    price REAL NOT NULL,
                    change_24h REAL,
                    change_percent_24h REAL,
                    volume_24h REAL,
                    high_24h REAL,
                    low_24h REAL,
                    market_cap REAL,
                    market_cap_rank INTEGER,
                    timestamp REAL NOT NULL,
                    source TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            
            conn.execute('''
                CREATE INDEX IF NOT EXISTS idx_symbol_timestamp 
                ON prices(symbol, timestamp)
            ''')
    
    def save_price(self, price: CryptoPrice):
        """Guardar precio en base de datos"""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute('''
                INSERT INTO prices (
                    symbol, price, change_24h, change_percent_24h,
                    volume_24h, high_24h, low_24h, market_cap,
                    market_cap_rank, timestamp, source
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                price.symbol, price.price, price.change_24h,
                price.change_percent_24h, price.volume_24h,
                price.high_24h, price.low_24h, price.market_cap,
                price.market_cap_rank, price.timestamp, price.source
            ))
    
    def get_historical_prices(self, symbol: str, hours: int = 24) -> List[Dict]:
        """Obtener precios históricos"""
        start_time = time.time() - (hours * 3600)
        
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute('''
                SELECT * FROM prices 
                WHERE symbol = ? AND timestamp >= ?
                ORDER BY timestamp ASC
            ''', (symbol, start_time))
            
            columns = [desc[0] for desc in cursor.description]
            return [dict(zip(columns, row)) for row in cursor.fetchall()]

class CryptoWebSocketManager:
    """Gestor de WebSocket para precios en tiempo real"""
    
    def __init__(self, callback: Callable[[CryptoPrice], None]):
        self.callback = callback
        self.ws = None
        self.running = False
        self.reconnect_attempts = 0
        self.max_reconnect_attempts = 10
        
    def start(self, symbols: List[str]):
        """Iniciar WebSocket"""
        self.running = True
        self.reconnect_attempts = 0
        
        # Crear streams para múltiples símbolos
        streams = '/'.join([f"{symbol.lower()}@ticker" for symbol in symbols])
        ws_url = f"wss://stream.binance.com:9443/ws/{streams}"
        
        logger.info(f"Conectando a WebSocket: {ws_url}")
        
        self.ws = websocket.WebSocketApp(
            ws_url,
            on_message=self._on_message,
            on_error=self._on_error,
            on_close=self._on_close,
            on_open=self._on_open
        )
        
        # Ejecutar en hilo separado
        ws_thread = threading.Thread(target=self.ws.run_forever)
        ws_thread.daemon = True
        ws_thread.start()
    
    def _on_message(self, ws, message):
        """Procesar mensaje de WebSocket"""
        try:
            data = json.loads(message)
            
            price = CryptoPrice(
                symbol=data.get('s', '').upper(),
                price=float(data.get('c', 0)),
                change_24h=float(data.get('p', 0)),
                change_percent_24h=float(data.get('P', 0)),
                volume_24h=float(data.get('v', 0)),
                high_24h=float(data.get('h', 0)),
                low_24h=float(data.get('l', 0)),
                source="Binance WebSocket"
            )
            
            self.callback(price)
            
        except Exception as e:
            logger.error(f"Error procesando mensaje WebSocket: {e}")
    
    def _on_error(self, ws, error):
        """Manejar errores de WebSocket"""
        logger.error(f"WebSocket error: {error}")
        self._schedule_reconnect()
    
    def _on_close(self, ws, close_status_code, close_msg):
        """WebSocket cerrado"""
        logger.warning(f"WebSocket cerrado: {close_status_code} - {close_msg}")
        if self.running:
            self._schedule_reconnect()
    
    def _on_open(self, ws):
        """WebSocket abierto"""
        logger.info("WebSocket conectado exitosamente")
        self.reconnect_attempts = 0
    
    def _schedule_reconnect(self):
        """Programar reconexión"""
        if self.reconnect_attempts < self.max_reconnect_attempts:
            self.reconnect_attempts += 1
            delay = min(2 ** self.reconnect_attempts, 60)  # Exponential backoff
            
            logger.info(f"Reconectando en {delay} segundos (intento {self.reconnect_attempts})")
            
            def reconnect():
                time.sleep(delay)
                if self.running:
                    self.ws.run_forever()
            
            thread = threading.Thread(target=reconnect)
            thread.daemon = True
            thread.start()
    
    def stop(self):
        """Detener WebSocket"""
        self.running = False
        if self.ws:
            self.ws.close()

class CryptoAPIManager:
    """Gestor de APIs REST para precios y datos históricos"""
    
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'InvictusTrader-Python/1.0',
            'Accept': 'application/json'
        })
        
        # URLs de APIs
        self.apis = {
            'coingecko': 'https://api.coingecko.com/api/v3',
            'binance': 'https://api.binance.com/api/v3',
            'cryptocompare': 'https://min-api.cryptocompare.com/data',
            'coinbase': 'https://api.exchange.coinbase.com'
        }
        
        # Mapeo de símbolos
        self.coingecko_ids = {
            'BTC': 'bitcoin', 'ETH': 'ethereum', 'BNB': 'binancecoin',
            'ADA': 'cardano', 'XRP': 'ripple', 'SOL': 'solana',
            'DOT': 'polkadot', 'DOGE': 'dogecoin', 'AVAX': 'avalanche-2',
            'MATIC': 'matic-network', 'LTC': 'litecoin', 'ATOM': 'cosmos',
            'LINK': 'chainlink', 'UNI': 'uniswap', 'LUNA': 'terra-luna-2',
            'SHIB': 'shiba-inu', 'TRX': 'tron', 'ETC': 'ethereum-classic',
            'FTT': 'ftx-token', 'NEAR': 'near', 'ALGO': 'algorand'
        }
    
    def get_current_prices(self, symbols: List[str], currency: str = 'USD') -> Dict[str, CryptoPrice]:
        """Obtener precios actuales de múltiples fuentes"""
        prices = {}
        
        # Intentar CoinGecko primero
        try:
            gecko_prices = self._get_prices_coingecko(symbols, currency)
            prices.update(gecko_prices)
            logger.info(f"CoinGecko: {len(gecko_prices)} precios obtenidos")
        except Exception as e:
            logger.warning(f"CoinGecko falló: {e}")
        
        # Complementar con Binance para símbolos faltantes
        missing_symbols = [s for s in symbols if s not in prices]
        if missing_symbols:
            try:
                binance_prices = self._get_prices_binance(missing_symbols, currency)
                prices.update(binance_prices)
                logger.info(f"Binance: {len(binance_prices)} precios adicionales")
            except Exception as e:
                logger.warning(f"Binance falló: {e}")
        
        # Último recurso: CryptoCompare
        missing_symbols = [s for s in symbols if s not in prices]
        if missing_symbols:
            try:
                cc_prices = self._get_prices_cryptocompare(missing_symbols, currency)
                prices.update(cc_prices)
                logger.info(f"CryptoCompare: {len(cc_prices)} precios adicionales")
            except Exception as e:
                logger.warning(f"CryptoCompare falló: {e}")
        
        return prices
    
    def _get_prices_coingecko(self, symbols: List[str], currency: str) -> Dict[str, CryptoPrice]:
        """Obtener precios desde CoinGecko"""
        # Filtrar símbolos válidos
        valid_symbols = [s for s in symbols if s.upper() in self.coingecko_ids]
        if not valid_symbols:
            return {}
        
        # Crear lista de IDs
        ids = [self.coingecko_ids[s.upper()] for s in valid_symbols]
        ids_str = ','.join(ids)
        
        url = f"{self.apis['coingecko']}/simple/price"
        params = {
            'ids': ids_str,
            'vs_currencies': currency.lower(),
            'include_24hr_change': 'true',
            'include_24hr_vol': 'true',
            'include_market_cap': 'true'
        }
        
        response = self.session.get(url, params=params, timeout=10)
        response.raise_for_status()
        
        data = response.json()
        prices = {}
        
        for symbol in valid_symbols:
            gecko_id = self.coingecko_ids[symbol.upper()]
            if gecko_id in data:
                coin_data = data[gecko_id]
                currency_lower = currency.lower()
                
                if currency_lower in coin_data:
                    prices[symbol.upper()] = CryptoPrice(
                        symbol=symbol.upper(),
                        price=coin_data[currency_lower],
                        change_24h=coin_data.get(f'{currency_lower}_24h_change', 0),
                        change_percent_24h=coin_data.get(f'{currency_lower}_24h_change', 0),
                        volume_24h=coin_data.get(f'{currency_lower}_24h_vol', 0),
                        market_cap=coin_data.get(f'{currency_lower}_market_cap', 0),
                        source="CoinGecko"
                    )
        
        return prices
    
    def _get_prices_binance(self, symbols: List[str], currency: str) -> Dict[str, CryptoPrice]:
        """Obtener precios desde Binance"""
        prices = {}
        currency_symbol = 'USDT' if currency.upper() == 'USD' else currency.upper()
        
        for symbol in symbols:
            try:
                pair = f"{symbol.upper()}{currency_symbol}"
                
                # Obtener precio actual
                price_url = f"{self.apis['binance']}/ticker/price"
                price_response = self.session.get(
                    price_url, 
                    params={'symbol': pair}, 
                    timeout=5
                )
                
                if price_response.status_code == 200:
                    price_data = price_response.json()
                    
                    # Obtener estadísticas 24h
                    stats_url = f"{self.apis['binance']}/ticker/24hr"
                    stats_response = self.session.get(
                        stats_url, 
                        params={'symbol': pair}, 
                        timeout=5
                    )
                    
                    if stats_response.status_code == 200:
                        stats_data = stats_response.json()
                        
                        prices[symbol.upper()] = CryptoPrice(
                            symbol=symbol.upper(),
                            price=float(price_data['price']),
                            change_24h=float(stats_data.get('priceChange', 0)),
                            change_percent_24h=float(stats_data.get('priceChangePercent', 0)),
                            volume_24h=float(stats_data.get('volume', 0)),
                            high_24h=float(stats_data.get('highPrice', 0)),
                            low_24h=float(stats_data.get('lowPrice', 0)),
                            source="Binance"
                        )
                
            except Exception as e:
                logger.warning(f"Error obteniendo {symbol} de Binance: {e}")
                continue
        
        return prices
    
    def _get_prices_cryptocompare(self, symbols: List[str], currency: str) -> Dict[str, CryptoPrice]:
        """Obtener precios desde CryptoCompare"""
        symbols_str = ','.join([s.upper() for s in symbols])
        
        url = f"{self.apis['cryptocompare']}/pricemultifull"
        params = {
            'fsyms': symbols_str,
            'tsyms': currency.upper()
        }
        
        response = self.session.get(url, params=params, timeout=10)
        response.raise_for_status()
        
        data = response.json()
        prices = {}
        
        if 'RAW' in data:
            for symbol in symbols:
                symbol_upper = symbol.upper()
                if symbol_upper in data['RAW'] and currency.upper() in data['RAW'][symbol_upper]:
                    coin_data = data['RAW'][symbol_upper][currency.upper()]
                    
                    prices[symbol_upper] = CryptoPrice(
                        symbol=symbol_upper,
                        price=coin_data.get('PRICE', 0),
                        change_24h=coin_data.get('CHANGE24HOUR', 0),
                        change_percent_24h=coin_data.get('CHANGEPCT24HOUR', 0),
                        volume_24h=coin_data.get('VOLUME24HOUR', 0),
                        high_24h=coin_data.get('HIGH24HOUR', 0),
                        low_24h=coin_data.get('LOW24HOUR', 0),
                        market_cap=coin_data.get('MKTCAP', 0),
                        source="CryptoCompare"
                    )
        
        return prices
    
    def get_historical_data(self, symbol: str, days: int = 7, interval: str = 'daily') -> List[Dict]:
        """Obtener datos históricos"""
        try:
            gecko_id = self.coingecko_ids.get(symbol.upper())
            if not gecko_id:
                return []
            
            url = f"{self.apis['coingecko']}/coins/{gecko_id}/market_chart"
            params = {
                'vs_currency': 'usd',
                'days': days,
                'interval': interval
            }
            
            response = self.session.get(url, params=params, timeout=15)
            response.raise_for_status()
            
            data = response.json()
            
            historical = []
            if 'prices' in data:
                for price_point in data['prices']:
                    historical.append({
                        'timestamp': price_point[0] / 1000,  # Convertir a segundos
                        'price': price_point[1],
                        'date': datetime.fromtimestamp(price_point[0] / 1000).isoformat()
                    })
            
            return historical
            
        except Exception as e:
            logger.error(f"Error obteniendo datos históricos para {symbol}: {e}")
            return []
    
    def get_top_cryptos(self, limit: int = 50) -> List[Dict]:
        """Obtener top criptomonedas por market cap"""
        try:
            url = f"{self.apis['coingecko']}/coins/markets"
            params = {
                'vs_currency': 'usd',
                'order': 'market_cap_desc',
                'per_page': limit,
                'page': 1,
                'sparkline': 'false',
                'price_change_percentage': '24h'
            }
            
            response = self.session.get(url, params=params, timeout=15)
            response.raise_for_status()
            
            data = response.json()
            
            return [{
                'symbol': coin['symbol'].upper(),
                'name': coin['name'],
                'image': coin['image'],
                'current_price': coin['current_price'],
                'market_cap': coin['market_cap'],
                'market_cap_rank': coin['market_cap_rank'],
                'price_change_24h': coin['price_change_24h'],
                'price_change_percentage_24h': coin['price_change_percentage_24h'],
                'total_volume': coin['total_volume'],
                'high_24h': coin['high_24h'],
                'low_24h': coin['low_24h']
            } for coin in data]
            
        except Exception as e:
            logger.error(f"Error obteniendo top cryptos: {e}")
            return []

class TechnicalAnalysis:
    """Análisis técnico básico"""
    
    @staticmethod
    def calculate_sma(prices: List[float], period: int) -> List[float]:
        """Calcular Simple Moving Average"""
        if len(prices) < period:
            return []
        
        sma = []
        for i in range(period - 1, len(prices)):
            avg = sum(prices[i - period + 1:i + 1]) / period
            sma.append(avg)
        
        return sma
    
    @staticmethod
    def calculate_rsi(prices: List[float], period: int = 14) -> List[float]:
        """Calcular Relative Strength Index"""
        if len(prices) < period + 1:
            return []
        
        deltas = [prices[i] - prices[i-1] for i in range(1, len(prices))]
        gains = [d if d > 0 else 0 for d in deltas]
        losses = [-d if d < 0 else 0 for d in deltas]
        
        avg_gain = sum(gains[:period]) / period
        avg_loss = sum(losses[:period]) / period
        
        rsi = []
        
        for i in range(period, len(gains)):
            avg_gain = (avg_gain * (period - 1) + gains[i]) / period
            avg_loss = (avg_loss * (period - 1) + losses[i]) / period
            
            if avg_loss == 0:
                rsi.append(100)
            else:
                rs = avg_gain / avg_loss
                rsi_value = 100 - (100 / (1 + rs))
                rsi.append(rsi_value)
        
        return rsi
    
    @staticmethod
    def detect_trend(prices: List[float], lookback: int = 20) -> str:
        """Detectar tendencia del mercado"""
        if len(prices) < lookback:
            return "NEUTRAL"
        
        recent_prices = prices[-lookback:]
        sma_short = sum(recent_prices[-5:]) / 5 if len(recent_prices) >= 5 else recent_prices[-1]
        sma_long = sum(recent_prices) / len(recent_prices)
        
        if sma_short > sma_long * 1.02:  # 2% por encima
            return "BULLISH"
        elif sma_short < sma_long * 0.98:  # 2% por debajo
            return "BEARISH"
        else:
            return "NEUTRAL"

class InvictusCryptoService:
    """Servicio principal de criptomonedas para Invictus Trader Pro"""
    
    def __init__(self, db_path: str = "crypto_prices.db"):
        self.db = CryptoPriceDatabase(db_path)
        self.api_manager = CryptoAPIManager()
        self.ws_manager = None
        self.price_cache = {}
        self.cache_timestamp = None
        self.cache_duration = 60  # 1 minuto
        
        # Callbacks para notificaciones
        self.price_update_callbacks = []
        
        logger.info("Invictus Crypto Service inicializado")
    
    def add_price_callback(self, callback: Callable[[CryptoPrice], None]):
        """Agregar callback para actualizaciones de precios"""
        self.price_update_callbacks.append(callback)
    
    def _notify_price_update(self, price: CryptoPrice):
        """Notificar actualización de precio"""
        # Guardar en base de datos
        self.db.save_price(price)
        
        # Actualizar cache
        self.price_cache[price.symbol] = price
        self.cache_timestamp = time.time()
        
        # Notificar callbacks
        for callback in self.price_update_callbacks:
            try:
                callback(price)
            except Exception as e:
                logger.error(f"Error en callback de precio: {e}")
    
    def start_realtime(self, symbols: List[str]) -> bool:
        """Iniciar precios en tiempo real"""
        try:
            if self.ws_manager:
                self.ws_manager.stop()
            
            self.ws_manager = CryptoWebSocketManager(self._notify_price_update)
            self.ws_manager.start(symbols)
            
            logger.info(f"WebSocket iniciado para símbolos: {symbols}")
            return True
            
        except Exception as e:
            logger.error(f"Error iniciando WebSocket: {e}")
            return False
    
    def stop_realtime(self):
        """Detener precios en tiempo real"""
        if self.ws_manager:
            self.ws_manager.stop()
            self.ws_manager = None
        logger.info("WebSocket detenido")
    
    def get_current_prices(self, symbols: List[str], use_cache: bool = True) -> Dict[str, Any]:
        """Obtener precios actuales"""
        # Verificar cache
        if (use_cache and self.cache_timestamp and 
            time.time() - self.cache_timestamp < self.cache_duration):
            
            cached_prices = {}
            for symbol in symbols:
                if symbol in self.price_cache:
                    cached_prices[symbol] = self.price_cache[symbol].to_dict()
            
            if len(cached_prices) == len(symbols):
                logger.info("Usando precios desde cache")
                return cached_prices
        
        # Obtener precios frescos
        try:
            prices = self.api_manager.get_current_prices(symbols)
            
            # Convertir a diccionario y actualizar cache
            result = {}
            for symbol, price in prices.items():
                result[symbol] = price.to_dict()
                self.price_cache[symbol] = price
            
            self.cache_timestamp = time.time()
            
            logger.info(f"Precios obtenidos: {len(result)} de {len(symbols)} símbolos")
            return result
            
        except Exception as e:
            logger.error(f"Error obteniendo precios: {e}")
            return {}
    
    def get_historical_data(self, symbol: str, days: int = 7) -> List[Dict]:
        """Obtener datos históricos"""
        try:
            # Primero intentar desde API
            data = self.api_manager.get_historical_data(symbol, days)
            
            if data:
                logger.info(f"Datos históricos obtenidos para {symbol}: {len(data)} puntos")
                return data
            
            # Fallback: obtener desde base de datos local
            hours = days * 24
            db_data = self.db.get_historical_prices(symbol, hours)
            
            if db_data:
                logger.info(f"Datos históricos desde BD para {symbol}: {len(db_data)} puntos")
                return db_data
            
            return []
            
        except Exception as e:
            logger.error(f"Error obteniendo datos históricos para {symbol}: {e}")
            return []
    
    def get_top_cryptos(self, limit: int = 50) -> List[Dict]:
        """Obtener top criptomonedas"""
        try:
            return self.api_manager.get_top_cryptos(limit)
        except Exception as e:
            logger.error(f"Error obteniendo top cryptos: {e}")
            return []
    
    def analyze_symbol(self, symbol: str, days: int = 30) -> Dict[str, Any]:
        """Análisis técnico de un símbolo"""
        try:
            # Obtener datos históricos
            historical = self.get_historical_data(symbol, days)
            
            if not historical:
                return {"error": "No hay datos históricos disponibles"}
            
            # Extraer precios
            prices = [point.get('price', 0) for point in historical]
            
            if len(prices) < 14:
                return {"error": "Datos insuficientes para análisis"}
            
            # Calcular indicadores
            sma_20 = TechnicalAnalysis.calculate_sma(prices, 20)
            rsi = TechnicalAnalysis.calculate_rsi(prices)
            trend = TechnicalAnalysis.detect_trend(prices)
            
            # Precio actual
            current_price = prices[-1] if prices else 0
            
            # Niveles de soporte y resistencia
            recent_prices = prices[-20:] if len(prices) >= 20 else prices
            support = min(recent_prices)
            resistance = max(recent_prices)
            
            analysis = {
                "symbol": symbol,
                "current_price": current_price,
                "trend": trend,
                "support_level": support,
                "resistance_level": resistance,
                "rsi_current": rsi[-1] if rsi else None,
                "sma_20_current": sma_20[-1] if sma_20 else None,
                "analysis_timestamp": time.time(),
                "data_points": len(prices)
            }
            
            # Señales de trading
            signals = []
            
            if rsi and rsi[-1] < 30:
                signals.append("RSI oversold - Potential BUY signal")
            elif rsi and rsi[-1] > 70:
                signals.append("RSI overbought - Potential SELL signal")
            
            if current_price <= support * 1.02:  # Cerca del soporte
                signals.append("Price near support level")
            elif current_price >= resistance * 0.98:  # Cerca de resistencia
                signals.append("Price near resistance level")
            
            analysis["signals"] = signals
            
            logger.info(f"Análisis completado para {symbol}")
            return analysis
            
        except Exception as e:
            logger.error(f"Error analizando {symbol}: {e}")
            return {"error": str(e)}
    
    def get_cache_status(self) -> Dict[str, Any]:
        """Estado del cache"""
        return {
            "has_cache": bool(self.price_cache),
            "cache_size": len(self.price_cache),
            "last_update": self.cache_timestamp,
            "minutes_since_update": (
                (time.time() - self.cache_timestamp) / 60 
                if self.cache_timestamp else None
            ),
            "symbols_cached": list(self.price_cache.keys())
        }
    
    def clear_cache(self):
        """Limpiar cache"""
        self.price_cache.clear()
        self.cache_timestamp = None
        logger.info("Cache limpiado")

# Instancia global del servicio
crypto_service = InvictusCryptoService()

# Funciones para la interfaz con Flutter
def start_crypto_service(symbols_str: str) -> str:
    """Iniciar servicio de criptomonedas"""
    try:
        symbols = [s.strip() for s in symbols_str.split(',') if s.strip()]
        success = crypto_service.start_realtime(symbols)
        
        if success:
            return json.dumps({"status": "success", "message": "Servicio iniciado"})
        else:
            return json.dumps({"status": "error", "message": "Error iniciando servicio"})
            
    except Exception as e:
        return json.dumps({"status": "error", "message": str(e)})

def get_current_prices_json(symbols_str: str) -> str:
    """Obtener precios actuales en JSON"""
    try:
        symbols = [s.strip() for s in symbols_str.split(',') if s.strip()]
        prices = crypto_service.get_current_prices(symbols)
        return json.dumps(prices)
        
    except Exception as e:
        logger.error(f"Error obteniendo precios: {e}")
        return json.dumps({"error": str(e)})

def get_historical_data_json(symbol: str, days: int = 7) -> str:
    """Obtener datos históricos en JSON"""
    try:
        data = crypto_service.get_historical_data(symbol, days)
        return json.dumps(data)
        
    except Exception as e:
        logger.error(f"Error obteniendo datos históricos: {e}")
        return json.dumps({"error": str(e)})

def get_top_cryptos_json(limit: int = 50) -> str:
    """Obtener top cryptos en JSON"""
    try:
        data = crypto_service.get_top_cryptos(limit)
        return json.dumps(data)
        
    except Exception as e:
        logger.error(f"Error obteniendo top cryptos: {e}")
        return json.dumps({"error": str(e)})

def analyze_symbol_json(symbol: str, days: int = 30) -> str:
    """Análisis técnico en JSON"""
    try:
        analysis = crypto_service.analyze_symbol(symbol, days)
        return json.dumps(analysis)
        
    except Exception as e:
        logger.error(f"Error analizando símbolo: {e}")
        return json.dumps({"error": str(e)})

def stop_crypto_service() -> str:
    """Detener servicio"""
    try:
        crypto_service.stop_realtime()
        return json.dumps({"status": "success", "message": "Servicio detenido"})
        
    except Exception as e:
        return json.dumps({"status": "error", "message": str(e)})

def get_cache_status_json() -> str:
    """Estado del cache en JSON"""
    try:
        status = crypto_service.get_cache_status()
        return json.dumps(status)
        
    except Exception as e:
        return json.dumps({"error": str(e)})

def clear_cache() -> str:
    """Limpiar cache"""
    try:
        crypto_service.clear_cache()
        return json.dumps({"status": "success", "message": "Cache limpiado"})
        
    except Exception as e:
        return json.dumps({"status": "error", "message": str(e)})

# Función principal para pruebas
if __name__ == "__main__":
    print("=== Invictus Crypto Service - Python Module ===")
    
    # Prueba básica
    symbols = ['BTC', 'ETH', 'BNB']
    print(f"\nObteniendo precios para: {symbols}")
    
    prices_json = get_current_prices_json(','.join(symbols))
    prices = json.loads(prices_json)
    
    for symbol, data in prices.items():
        if isinstance(data, dict) and 'price' in data:
            print(f"{symbol}: ${data['price']:.2f} ({data.get('change_percent_24h', 0):+.2f}%)")
    
    print(f"\n✅ Módulo Python funcionando correctamente!")
