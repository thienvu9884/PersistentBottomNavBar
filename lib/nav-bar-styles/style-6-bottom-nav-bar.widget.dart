import 'dart:ui';

import 'package:flutter/material.dart';
import '../persistent-tab-view.dart';

class BottomNavStyle6 extends StatefulWidget {
  final int selectedIndex;
  final double iconSize;
  final Color backgroundColor;
  final bool showElevation;
  final Duration animationDuration;
  final List<PersistentBottomNavBarItem> items;
  final ValueChanged<int> onItemSelected;
  final double navBarHeight;
  final NavBarCurve navBarCurve;
  final double bottomPadding;
  final double horizontalPadding;

  BottomNavStyle6(
      {Key key,
      this.selectedIndex,
      this.showElevation = false,
      this.iconSize,
      this.backgroundColor,
      this.animationDuration = const Duration(milliseconds: 1000),
      this.navBarHeight = 0.0,
      @required this.items,
      this.onItemSelected,
      this.bottomPadding,
      this.horizontalPadding,
      this.navBarCurve});

  @override
  _BottomNavStyle6State createState() => _BottomNavStyle6State();
}

class _BottomNavStyle6State extends State<BottomNavStyle6> with TickerProviderStateMixin {
  List<AnimationController> _animationControllerList;
  List<Animation<double>> _animationList;

  int _lastSelectedIndex;
  int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _lastSelectedIndex = 0;
    _selectedIndex = 0;
    _animationControllerList = List<AnimationController>();
    _animationList = List<Animation<double>>();

    for (int i = 0; i < widget.items.length; ++i) {
      _animationControllerList.add(AnimationController(duration: Duration(milliseconds: 400), vsync: this));
      _animationList.add(Tween(begin: 0.95, end: 1.18).chain(CurveTween(curve: Curves.ease)).animate(_animationControllerList[i]));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationControllerList[_selectedIndex].forward();
    });
  }

  Widget _buildItem(PersistentBottomNavBarItem item, bool isSelected, double height, int itemIndex) {
    return AnimatedBuilder(
      animation: _animationList[itemIndex],
      builder: (context, child) => Transform.scale(
        scale: _animationList[itemIndex].value,
        child: Container(
          width: 150.0,
          height: height,
          child: Container(
            alignment: Alignment.center,
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: IconTheme(
                    data: IconThemeData(
                        size: widget.iconSize,
                        color: isSelected
                            ? (item.activeContentColor == null ? item.activeColor : item.activeContentColor)
                            : item.inactiveColor == null ? item.activeColor : item.inactiveColor),
                    child: item.icon,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: FittedBox(
                      child: Text(
                        item.title,
                        style: TextStyle(
                            color: isSelected ? (item.activeContentColor == null ? item.activeColor : item.activeContentColor) : item.inactiveColor,
                            fontWeight: FontWeight.w400,
                            fontSize: item.titleFontSize),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (int i = 0; i < widget.items.length; ++i) {
      _animationControllerList[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedIndex != _selectedIndex) {
      _lastSelectedIndex = _selectedIndex;
      _selectedIndex = widget.selectedIndex;
      _animationControllerList[_selectedIndex].forward();
      _animationControllerList[_lastSelectedIndex].reverse();
    }
    return Container(
      decoration: getNavBarDecoration(
        navBarCurve: widget.navBarCurve,
        showElevation: widget.showElevation,
      ),
      child: ClipRRect(
        borderRadius: getClipRectBorderRadius(navBarCurve: widget.navBarCurve),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Container(
            color: getBackgroundColor(context, widget.items, widget.backgroundColor, widget.selectedIndex),
            child: Container(
              width: double.infinity,
              height: widget.navBarHeight,
              padding: EdgeInsets.only(
                  left: widget.horizontalPadding == null ? MediaQuery.of(context).size.width * 0.04 : widget.horizontalPadding,
                  right: widget.horizontalPadding == null ? MediaQuery.of(context).size.width * 0.04 : widget.horizontalPadding,
                  top: widget.navBarHeight * 0.15,
                  bottom: widget.bottomPadding == null ? widget.navBarHeight * 0.12 : widget.bottomPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: widget.items.map((item) {
                  var index = widget.items.indexOf(item);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (index != _selectedIndex) {
                          _lastSelectedIndex = _selectedIndex;
                          _selectedIndex = index;
                          _animationControllerList[_selectedIndex].forward();
                          _animationControllerList[_lastSelectedIndex].reverse();
                        }
                        widget.onItemSelected(index);
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: _buildItem(item, widget.selectedIndex == index, widget.navBarHeight, index),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
