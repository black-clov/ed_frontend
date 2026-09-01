import 'package:flutter/material.dart';

import '../models/recommendation_model.dart';
import '../services/recommendations_service.dart';
import 'package:flutter_application_1/core/i18n/app_i18n.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('emp2_recommendations_title'))),
      body: FutureBuilder<List<RecommendationModel>>(
        future: RecommendationsService().getRecommendations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final recommendations = snapshot.data ?? const [];
          if (recommendations.isEmpty) {
            return Center(child: Text(tr('emp2_no_recommendations')));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final item = recommendations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(item.description),
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(item.actionLabel),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
