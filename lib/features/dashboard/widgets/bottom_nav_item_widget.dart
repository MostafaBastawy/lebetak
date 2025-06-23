import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String selectedIcon;
  final String unSelectedIcon;
  final String title;
  final Function? onTap;
  final bool isSelected;
  final double iconSize;
  final double fontSize;

  const BottomNavItemWidget({
    super.key,
    this.onTap,
    this.isSelected = false,
    required this.title,
    required this.selectedIcon,
    required this.unSelectedIcon,
    this.iconSize = 25, // ← الحجم الافتراضي للأيقونة
    this.fontSize = 12, // ← الحجم الافتراضي للنص
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Image.asset(
            isSelected ? selectedIcon : unSelectedIcon,
            height: iconSize,
            width: iconSize,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.black54/*Theme.of(context).textTheme.bodyMedium!.color!*/,
          ),

          SizedBox(height: isSelected
              ? Dimensions.paddingSizeExtraSmall
              : Dimensions.paddingSizeSmall),

          Text(
            title,
            style: AlmaraiRegular.copyWith(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  :Colors.black54/*Theme.of(context).textTheme.bodyMedium!.color!*/,
              fontSize: fontSize,
            ),
          ),

        ],
      ),
    );
  }
}
