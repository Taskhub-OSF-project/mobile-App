import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/portfolio_models.dart';
import '../../../../shared/widgets/common_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class PortfolioGridWidget extends StatelessWidget {
  final List<PortfolioItemResponse> items;
  final bool isOwner;
  final VoidCallback? onAdd;
  final Function(int)? onDelete;

  const PortfolioGridWidget({
    super.key,
    required this.items,
    this.isOwner = false,
    this.onAdd,
    this.onDelete,
  });

  Future<void> _launchUrl(String? urlStr) async {
    if (urlStr == null || urlStr.isEmpty) return;
    final url = Uri.tryParse(urlStr);
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isOwner) {
      return const EmptyState(
        icon: Icons.work_outline,
        title: 'Chưa có dự án nào',
        subtitle: 'Người dùng này chưa thêm dự án vào hồ sơ.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isOwner) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Thêm dự án'),
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: EmptyState(
                icon: Icons.add_photo_alternate_outlined,
                title: 'Hồ sơ năng lực trống',
                subtitle: 'Thêm dự án để thu hút nhiều người thuê hơn.',
              ),
            ),
        ],
        if (items.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _launchUrl(item.projectUrl),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: item.imageUrls.isNotEmpty
                                  ? Image.network(item.imageUrls.first, fit: BoxFit.cover)
                                  : const Icon(Icons.image, size: 40, color: Colors.grey),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (item.description != null)
                                  Text(
                                    item.description!,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (isOwner && onDelete != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, size: 14, color: Colors.white),
                              onPressed: () => onDelete!(item.id),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
