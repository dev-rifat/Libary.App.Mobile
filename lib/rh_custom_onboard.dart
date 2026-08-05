/// Swipeable onboarding flow: image + title/description per page, active-dot
/// indicator, and a combined next/skip control that turns into "done" on
/// the last page.
///
/// Work procedure:
/// 1. Build the page list as [OnBoardModel]s (title, description, image —
///    `.svg` or raster asset paths both work).
/// 2. Pass [onRoutePathAction] — called both by the skip button and
///    automatically when "next" is tapped on the last page (i.e. it's your
///    "onboarding finished, navigate away" callback, not a per-page hook).
/// 3. [bgColor] drives the active dot, next-button circle, and skip text
///    color together — override text/button styles individually only when
///    the default derived styling doesn't fit.
///
/// Usage:
/// ```dart
/// RHCustomOnboard(
///   bgColor: Colors.blue,
///   onRoutePathAction: () => context.go('/home'),
///   onBoardModel: [
///     OnBoardModel(title: 'Welcome', description: 'Track your reads', image: 'assets/onboard1.svg'),
///     OnBoardModel(title: 'Discover', description: 'Find your next book', image: 'assets/onboard2.svg'),
///   ],
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RHCustomOnboard extends StatefulWidget {
  /// Drives the active dot, next-button circle background, and skip text
  /// color. Defaults to blue.
  final Color? bgColor;

  /// Pages to show, one per [OnBoardModel].
  final List<OnBoardModel> onBoardModel;

  /// Called when skip is tapped, or when next is tapped on the last page.
  final Function onRoutePathAction;

  /// Style for each page's description text.
  final TextStyle? descriptionTextStyle;

  /// Style for the skip button's label.
  final TextStyle? skipBtnTextStyle;

  /// Style for each page's title text.
  final TextStyle? titleTextStyle;

  /// Style for the next/done circular button's label/icon text.
  final TextStyle? btnTextStyle;

  /// Skip button label. Defaults to "Skip" (and "Done" on the last page).
  final String? skipBtnText;

  /// Next-button label shown instead of the arrow icon, on non-last pages.
  final String? nextBtnText;

  /// Next-button label shown instead of the check icon, on the last page.
  final String? completedBtnText;
  const RHCustomOnboard({
    super.key,
    this.bgColor = Colors.blue,
    this.titleTextStyle,
    this.skipBtnTextStyle,
    this.descriptionTextStyle,
    this.btnTextStyle,
    this.skipBtnText,
    this.completedBtnText,
    this.nextBtnText,
    required this.onRoutePathAction,
    required this.onBoardModel,
  });

  @override
  State<RHCustomOnboard> createState() => _RHCustomOnboardState();
}

class _RHCustomOnboardState extends State<RHCustomOnboard> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.onBoardModel.length,
      onPageChanged: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(left: 17.0, right: 17, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ///Onboard Image
              _imageLayout(index),

              ///Onboard body
              _onboardBodyLayout(index, context, widget.skipBtnTextStyle),
            ],
          ),
        );
      },
    );
  }

  _imageLayout(index) {
    return widget.onBoardModel[index].image.endsWith(".svg")
        ? _svgImage(index)
        : _assetImage(index);
  }

  _assetImage(index) {
    return Expanded(
      child: Image.asset(widget.onBoardModel[index].image),
    );
  }

  _onboardBodyLayout(int index, context, skipBtnTextStyle) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: widget.bgColor?.withValues(alpha: 0.1),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 12.0, bottom: 12, left: 20, right: 20),
        child: Column(
          children: [
            _activeDot(),
            _spacer(20),
            _onboardTitleText(
                text: widget.onBoardModel[index].title,
                textStyle: widget.titleTextStyle),
            _spacer(12),
            _descriptionText(
                text: widget.onBoardModel[index].description,
                textStyle: widget.descriptionTextStyle),
            _spacer(50),
            _buttonLayout(
                skipBtnText: widget.skipBtnText,
                skipAction: widget.onRoutePathAction,
                bgColor: widget.bgColor,
                index: currentIndex,
                textStyle: widget.btnTextStyle,
                length: widget.onBoardModel.length - 1,
                skipBtnTextStyle: skipBtnTextStyle,
                nextBtnText: widget.nextBtnText,
                completedBtnText: widget.completedBtnText,
                onAction: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );

                  if (currentIndex == widget.onBoardModel.length - 1) {
                    widget.onRoutePathAction();
                  }
                }),
          ],
        ),
      ),
    );
  }

  _activeDot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.onBoardModel.length, (index) {
        return ActiveDot(
          isActive: currentIndex == index,
          bgColor: widget.bgColor,
        );
      }),
    );
  }

  _spacer(double height) {
    return SizedBox(
      height: height,
    );
  }

  _svgImage(index) {
    return Expanded(
      child: _onboardByImage(imageUrl: widget.onBoardModel[index].image),
    );
  }
}

Widget _buttonLayout(
    {context,
    onAction,
    int index = 0,
    bgColor,
    skipAction,
    required int length,
    String? skipBtnText,
    String? nextBtnText,
    String? completedBtnText,
    TextStyle? textStyle,
    TextStyle? skipBtnTextStyle}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      GestureDetector(
        onTap: onAction,
        child: CircleAvatar(
          radius: 27,
          backgroundColor: bgColor,
          child: nextBtnText == null
              ? _iconLayout(index, length)
              : index == length
                  ? Text("$completedBtnText",
                      style: textStyle ?? const TextStyle(color: Colors.white))
                  : Text(
                      nextBtnText,
                      style: textStyle ?? const TextStyle(color: Colors.white),
                    ),
        ),
      ),
      const SizedBox(
        height: 18,
      ),
      _skipButton(
          context: context,
          bgColor: bgColor,
          textStyle: skipBtnTextStyle,
          skipAction: skipAction,
          skipBtnText: index == length ? "Done" : skipBtnText),
    ],
  );
}

_iconLayout(index, length) {
  return index == length
      ? const Icon(
          Icons.done,
          color: Colors.white,
          size: 30,
        )
      : const Icon(
          Icons.arrow_forward,
          color: Colors.white,
          size: 30,
        );
}

Widget _skipButton(
    {context, bgColor, skipAction, TextStyle? textStyle, String? skipBtnText}) {
  return TextButton(
    onPressed: () async {
      await skipAction();
    },
    child: Text(
      skipBtnText ?? "Skip",
      style: textStyle ??
          TextStyle(
            fontSize: 16,
            color: bgColor,
            fontWeight: FontWeight.w500,
          ),
    ),
  );
}

Widget _onboardByImage({required imageUrl}) {
  return Center(
    child: SvgPicture.asset(
      imageUrl.toString(),
      fit: BoxFit.cover,
    ),
  );
}

Widget _descriptionText({required text, TextStyle? textStyle}) {
  return Text(
    text,
    maxLines: 5,
    style: textStyle ??
        const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w300,
          overflow: TextOverflow.ellipsis,
        ),
    textAlign: TextAlign.center,
  );
}

Widget _onboardTitleText({text, TextStyle? textStyle}) {
  return Text(
    text,
    maxLines: 2,
    style: textStyle ??
        const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black,
          overflow: TextOverflow.ellipsis,
        ),
    textAlign: TextAlign.center,
  );
}

/// Single dot in [RHCustomOnboard]'s page indicator; a ringed circle when
/// active, a faded fill otherwise.
class ActiveDot extends StatelessWidget {
  /// Whether this dot represents the current page.
  final bool isActive;

  /// Dot color when active (and at 50% opacity when inactive).
  final Color? bgColor;

  const ActiveDot({super.key, this.isActive = false, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: CircleAvatar(
          radius: 9,
          backgroundColor: isActive ? bgColor : Colors.transparent,
          child: CircleAvatar(
            radius: 8,
            backgroundColor: isActive ? Colors.white : Colors.transparent,
            child: CircleAvatar(
              radius: 6,
              backgroundColor:
                  isActive ? bgColor : bgColor?.withValues(alpha: 0.5),
            ),
          ),
        ));
  }
}

/// One onboarding page's content for [RHCustomOnboard].
class OnBoardModel {
  /// Page title.
  String title;

  /// Page description/body text.
  String description;

  /// Asset path to the page image (`.svg` or raster).
  String image;

  OnBoardModel(
      {required this.title, required this.description, required this.image});
}
