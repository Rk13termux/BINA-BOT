#!/usr/bin/env python3
"""
Script de instalación de dependencias para Invictus Trader Pro
Instala todas las dependencias necesarias para el módulo Python
"""

import subprocess
import sys
import os

def install_package(package):
    """Instalar un paquete usando pip"""
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
        print(f"✅ {package} instalado correctamente")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error instalando {package}: {e}")
        return False

def check_python_version():
    """Verificar versión de Python"""
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 7):
        print("❌ Se requiere Python 3.7 o superior")
        return False
    
    print(f"✅ Python {version.major}.{version.minor}.{version.micro} detectado")
    return True

def main():
    print("🐍 Configurando dependencias Python para Invictus Trader Pro...")
    print("=" * 60)
    
    # Verificar versión de Python
    if not check_python_version():
        sys.exit(1)
    
    # Lista de dependencias requeridas
    dependencies = [
        "requests>=2.31.0",
        "websocket-client>=1.6.0", 
        "pandas>=2.0.0",
        "numpy>=1.24.0",
        "sqlite3"  # Incluido en Python estándar
    ]
    
    # Dependencias opcionales para análisis avanzado
    optional_dependencies = [
        "scipy>=1.10.0",
        "matplotlib>=3.7.0",
        "ta>=0.10.0",  # Análisis técnico
        "yfinance>=0.2.0",  # Datos financieros adicionales
    ]
    
    print("\n📦 Instalando dependencias requeridas...")
    success_count = 0
    
    for package in dependencies:
        if package == "sqlite3":
            print(f"✅ {package} (incluido en Python estándar)")
            success_count += 1
        else:
            if install_package(package):
                success_count += 1
    
    print(f"\n✅ {success_count}/{len(dependencies)} dependencias requeridas instaladas")
    
    print("\n📦 Instalando dependencias opcionales...")
    optional_success = 0
    
    for package in optional_dependencies:
        if install_package(package):
            optional_success += 1
    
    print(f"\n✅ {optional_success}/{len(optional_dependencies)} dependencias opcionales instaladas")
    
    # Verificar instalación
    print("\n🔍 Verificando instalación...")
    
    try:
        import requests
        import websocket
        import pandas as pd
        import numpy as np
        import sqlite3
        print("✅ Todas las dependencias principales están disponibles")
        
        # Verificar opcionales
        optional_available = []
        try:
            import scipy
            optional_available.append("scipy")
        except ImportError:
            pass
            
        try:
            import matplotlib
            optional_available.append("matplotlib")
        except ImportError:
            pass
            
        try:
            import ta
            optional_available.append("ta")
        except ImportError:
            pass
            
        if optional_available:
            print(f"✅ Dependencias opcionales disponibles: {', '.join(optional_available)}")
        
        print("\n🎉 ¡Configuración completada exitosamente!")
        print("\n💡 Ahora puedes usar el módulo Python completo en Invictus Trader Pro")
        
        # Crear un script de prueba
        test_script = """
# Prueba rápida del módulo crypto_service
try:
    import sys
    import os
    
    # Agregar directorio actual al path
    current_dir = os.path.dirname(os.path.abspath(__file__))
    sys.path.append(current_dir)
    
    # Importar y probar
    from crypto_service import get_current_prices_json
    
    print("🧪 Probando obtención de precios...")
    result = get_current_prices_json("BTC,ETH")
    print(f"✅ Resultado: {result[:100]}...")
    
except Exception as e:
    print(f"⚠️ Error en prueba: {e}")
"""
        
        with open("test_crypto_module.py", "w") as f:
            f.write(test_script)
        
        print("\n📝 Script de prueba creado: test_crypto_module.py")
        print("   Ejecuta: python test_crypto_module.py")
        
    except ImportError as e:
        print(f"❌ Error verificando dependencias: {e}")
        print("💡 Intenta ejecutar el script nuevamente")
        sys.exit(1)

if __name__ == "__main__":
    main()
