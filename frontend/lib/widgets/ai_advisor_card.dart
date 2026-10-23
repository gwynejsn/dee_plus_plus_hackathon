import 'package:flutter/material.dart';

import '../config/soft_ui_theme.dart';
import '../models/ai_prediction.dart';
import '../models/service_model.dart';

class AiAdvisorCard extends StatelessWidget {
  final List<ServiceModel> services;
  final String? selectedServiceId;
  final AiPrediction? prediction;
  final bool isLoading;
  final ValueChanged<String?> onServiceSelected;

  const AiAdvisorCard({
    super.key,
    required this.services,
    required this.selectedServiceId,
    required this.prediction,
    required this.isLoading,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    Color riskColor = SoftUiTheme.primaryMint;
    Color riskBg = SoftUiTheme.mintLight;

    if (prediction?.bottleneckRisk == 'HIGH') {
      riskColor = SoftUiTheme.redDanger;
      riskBg = SoftUiTheme.redLight;
    } else if (prediction?.bottleneckRisk == 'MEDIUM') {
      riskColor = SoftUiTheme.amberWarning;
      riskBg = SoftUiTheme.amberLight;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SoftUiTheme.cardBg,
        borderRadius: SoftUiTheme.cardRadius,
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: SoftUiTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF9333EA),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Gemini AI Wait Advisor',
                    style: TextStyle(
                      color: SoftUiTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Operations AI',
                  style: TextStyle(
                    color: Color(0xFF9333EA),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Service Dropdown
          if (services.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: selectedServiceId ?? services.first.id,
              decoration: InputDecoration(
                labelText: 'Select Service to Analyze',
                labelStyle: const TextStyle(
                  color: SoftUiTheme.textSecondary,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: SoftUiTheme.primaryMint,
                    width: 2,
                  ),
                ),
              ),
              dropdownColor: SoftUiTheme.cardBg,
              style: const TextStyle(
                color: SoftUiTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              items: services.map((s) {
                return DropdownMenuItem<String>(
                  value: s.id,
                  child: Text(
                    '${s.name} (~${s.baselineDurationMinutes}m)',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: onServiceSelected,
            ),
          ],

          const SizedBox(height: 16),

          if (isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: SoftUiTheme.primaryMint,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Evaluating historical telemetry via Gemini AI...',
                      style: TextStyle(
                        color: SoftUiTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (prediction != null) ...[
            // KPI Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI PREDICTED DURATION',
                          style: TextStyle(
                            color: SoftUiTheme.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${prediction!.predictedDurationMinutes} mins',
                          style: const TextStyle(
                            color: Color(0xFF9333EA),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: riskBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: riskColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BOTTLENECK RISK',
                          style: TextStyle(
                            color: SoftUiTheme.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${prediction!.bottleneckRisk} RISK',
                          style: TextStyle(
                            color: riskColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Advice Callout Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5FF),
                borderRadius: BorderRadius.circular(14),
                border: const Border(
                  left: BorderSide(color: Color(0xFF9333EA), width: 3.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Color(0xFF7E22CE),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Actionable MSME Advice:',
                        style: TextStyle(
                          color: Color(0xFF7E22CE),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prediction!.operationalAdvice.isNotEmpty
                        ? prediction!.operationalAdvice
                        : prediction!.summaryInsight,
                    style: const TextStyle(
                      color: SoftUiTheme.textPrimary,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
