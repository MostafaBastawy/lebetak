import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../common/controllers/theme_controller.dart';
import '../../../helper/auth_helper.dart';
import '../../../helper/price_converter.dart';
import '../../../util/images.dart';
import '../../menu/widgets/portion_widget.dart';
import '../../profile/controllers/profile_controller.dart';

class BannerView extends StatelessWidget {
  final bool isFeatured;
  final bool searchBgShow = false;
  const BannerView({super.key, required this.isFeatured});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<BannerController>(builder: (bannerController) {
      List<String?>? bannerList = isFeatured ? bannerController.featuredBannerList : bannerController.bannerImageList;
      List<dynamic>? bannerDataList = isFeatured ? bannerController.featuredBannerDataList : bannerController.bannerDataList;
      final bool isLoggedIn = AuthHelper.isLoggedIn();
      return (bannerList != null && bannerList.isEmpty) ? const SizedBox() : Container(
        width: MediaQuery.of(context).size.width,
        height: GetPlatform.isDesktop ? 500 : MediaQuery.of(context).size.width * 1.0,
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: bannerList != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(
              height: 50, width: Dimensions.webMaxWidth,
              color: searchBgShow ? Get.find<ThemeController>().darkTheme ? Theme.of(context).colorScheme.surface : Theme.of(context).cardColor : null,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: InkWell(
                onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 1),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: Row(children: [
                    Icon(
                      CupertinoIcons.search, size: 25,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Expanded(child: Text(
                      Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr,
                      style: AlmaraiRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor,
                      ),
                    )),
                  ]),
                ),
              ),
            )
            ),

            const SizedBox(height: Dimensions.paddingSizeExtraSmall+5),




           // const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            // ✅ البانر
            Expanded(
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  disableCenter: true,
                  viewportFraction: 0.8,
                  autoPlayInterval: const Duration(seconds: 7),
                  onPageChanged: (index, reason) {
                    bannerController.setCurrentIndex(index, true);
                  },
                ),
                itemCount: bannerList.isEmpty ? 1 : bannerList.length,
                itemBuilder: (context, index, _) {
                  return InkWell(
                    onTap: () async {
                      if (bannerDataList![index] is Item) {
                        Item? item = bannerDataList[index];
                        Get.find<ItemController>().navigateToItemPage(item, context);
                      } else if (bannerDataList[index] is Store) {
                        Store? store = bannerDataList[index];
                        if (isFeatured &&
                            (AddressHelper.getUserAddressFromSharedPref()!.zoneData != null &&
                                AddressHelper.getUserAddressFromSharedPref()!.zoneData!.isNotEmpty)) {
                          for (ModuleModel module in Get.find<SplashController>().moduleList!) {
                            if (module.id == store!.moduleId) {
                              Get.find<SplashController>().setModule(module);
                              break;
                            }
                          }
                          ZoneData zoneData = AddressHelper.getUserAddressFromSharedPref()!.zoneData!
                              .firstWhere((data) => data.id == store!.zoneId);
                          Modules module = zoneData.modules!
                              .firstWhere((module) => module.id == store!.moduleId);
                          Get.find<SplashController>().setModule(ModuleModel(
                            id: module.id,
                            moduleName: module.moduleName,
                            moduleType: module.moduleType,
                            themeId: module.themeId,
                            storesCount: module.storesCount,
                          ));
                        }
                        Get.toNamed(
                          RouteHelper.getStoreRoute(id: store!.id, page: isFeatured ? 'module' : 'banner'),
                          arguments: StoreScreen(store: store, fromModule: isFeatured),
                        );
                      } else if (bannerDataList[index] is BasicCampaignModel) {
                        BasicCampaignModel campaign = bannerDataList[index];
                        Get.toNamed(RouteHelper.getBasicCampaignRoute(campaign));
                      } else {
                        String url = bannerDataList[index];
                        if (await canLaunchUrlString(url)) {
                          await launchUrlString(url, mode: LaunchMode.externalApplication);
                        } else {
                          showCustomSnackBar('unable_to_found_url'.tr);
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 0)],
                      ),
                      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: GetBuilder<SplashController>(builder: (splashController) {
                          return CustomImage(
                            image: '${bannerList[index]}',
                            fit: BoxFit.cover,
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            // ✅ مؤشّرات البانر
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: bannerList.map((bnr) {
                int index = bannerList.indexOf(bnr);
                int totalBanner = bannerList.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: index == bannerController.currentIndex
                      ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    child: Text('${index + 1}/$totalBanner',
                        style: AlmaraiRegular.copyWith(
                            color: Theme.of(context).cardColor, fontSize: 12)),
                  )
                      : Container(
                    height: 5,
                    width: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: Dimensions.paddingSizeExtraSmall-2),

            GetBuilder<ProfileController>(
              builder: (profileController) {
                return Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // مربع كوبون
                      Container(
                        width: 165, // حجم صغير حسب الطلب
                        height: 70,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: PortionWidget(
                            icon: Images.couponIcon,
                            title: 'coupon'.tr,
                            route: RouteHelper.getCouponRoute(),
                            hideDivider: Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 ||
                                Get.find<SplashController>().configModel!.customerWalletStatus == 1
                                ? true
                                : true,
                          ),
                        ),
                      ),

                      // مربع محفظتي (إذا كانت مفعلة)
                      if (Get.find<SplashController>().configModel!.customerWalletStatus == 1)
                        Container(
                          width: 165, // حجم صغير حسب الطلب
                          height: 70,
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
                            ],
                          ),
                          child: PortionWidget(
                            icon: Images.walletIcon,
                            title: 'my_wallet'.tr,
                            route: RouteHelper.getWalletRoute(),
                            hideDivider: true,
                            suffix: !isLoggedIn
                                ? null
                                : PriceConverter.convertPrice(profileController.userInfoModel?.walletBalance ?? 0),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall-2),
            // ✅ مرحباً يا [اسم المستخدم]
           /* Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
               // vertical: Dimensions.paddingSizeSmall,
              ),
              child: GetBuilder<ProfileController>(
                builder: (profileController) {
                  final bool isLoggedIn = AuthHelper.isLoggedIn();
                  final String userName = isLoggedIn
                      ? '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}'
                      : 'زائر';
                  return Text(
                    'مرحباً يا $userName',
                    style: AlmaraiBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            ),*/
           /* const SizedBox(height: Dimensions.paddingSizeExtraSmall+3),

            Center(child: Container(
              height: 50, width: Dimensions.webMaxWidth,
              color: searchBgShow ? Get.find<ThemeController>().darkTheme ? Theme.of(context).colorScheme.surface : Theme.of(context).cardColor : null,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: InkWell(
                onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 1),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: Row(children: [
                    Icon(
                      CupertinoIcons.search, size: 25,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Expanded(child: Text(
                      Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr,
                      style: AlmaraiRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor,
                      ),
                    )),
                  ]),
                ),
              ),
            )
            ),

            const SizedBox(height: Dimensions.paddingSizeExtraSmall-2),*/


          ],
        )
            : Shimmer(
          duration: const Duration(seconds: 2),
          enabled: bannerList == null,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Colors.grey[300],
            ),
          ),
        ),
      );

    });
  }

}
