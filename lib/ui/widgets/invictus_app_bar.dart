import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../../services/binance_service.dart';
import '../../services/ai_service.dart';

/// Barra superior profesional personalizada para INVICTUS TRADER PRO
class InvictusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBalance;
  final bool showConnectionStatus;
  final VoidCallback? onMenuPressed;

  const InvictusAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBalance = true,
    this.showConnectionStatus = true,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundBlack,
            AppColors.surfaceDark,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.goldPrimary.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Logo y menú
              _buildLeadingSection(context),
              
              // Título central
              Expanded(child: _buildTitleSection()),
              
              // Sección derecha con balance y estado
              _buildTrailingSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón de menú orbital
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onMenuPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.goldPrimary, AppColors.goldDeep],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Logo compacto
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.goldPrimary, AppColors.goldSecondary],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.trending_up,
            color: Colors.black,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'INVICTUS TRADER PRO',
            style: TextStyle(
              color: AppColors.goldPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Balance (si está habilitado)
        if (showBalance) _buildBalanceWidget(),
        
        const SizedBox(height: 4),
        
        // Estado de conexión (si está habilitado)
        if (showConnectionStatus) _buildConnectionStatus(),
      ],
    );
  }

  Widget _buildBalanceWidget() {
    return Consumer<BinanceService>(
      builder: (context, binanceService, child) {
        if (!binanceService.isAuthenticated) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.bearish.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.bearish, width: 0.5),
            ),
            child: Text(
              'NO CONECTADO',
              style: TextStyle(
                color: AppColors.bearish,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        return FutureBuilder<double>(
          future: binanceService.getTotalBalanceUSDT(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data! > 0) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.goldPrimary.withOpacity(0.2),
                      AppColors.goldDeep.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.goldPrimary, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.goldPrimary,
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${snapshot.data!.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.goldPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildConnectionStatus() {
    return Consumer2<BinanceService, AIService>(
      builder: (context, binanceService, aiService, child) {
        final isConnected = binanceService.isAuthenticated && binanceService.isConnected;
        final aiStatus = aiService.isInitialized;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Estado Binance
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isConnected ? AppColors.bullish : AppColors.bearish,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isConnected ? AppColors.bullish : AppColors.bearish,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 4),
            
            // Estado IA
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: aiStatus ? AppColors.info : AppColors.neutral,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: aiStatus ? AppColors.info : AppColors.neutral,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 6),
            
            Text(
              isConnected ? 'LIVE' : 'OFFLINE',
              style: TextStyle(
                color: isConnected ? AppColors.bullish : AppColors.bearish,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// AppBar simplificada para pantallas internas
class InvictusSimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const InvictusSimpleAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundBlack,
            AppColors.surfaceDark,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.goldPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Botón de retroceso
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBackPressed ?? () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.goldPrimary.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.goldPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Título y subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: AppColors.goldPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Acciones adicionales
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}
