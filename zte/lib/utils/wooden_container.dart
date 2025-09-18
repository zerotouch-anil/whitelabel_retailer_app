import 'package:flutter/material.dart';

class WoodContainer extends StatelessWidget {
  final double height;
  final Widget child;
  const WoodContainer({super.key, required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withAlpha(100),
                offset: Offset(-3, -3),
                spreadRadius: .2,
                blurRadius: 8
              ),
              BoxShadow(
                color: Colors.black.withAlpha(120),
                offset: Offset(3, 3),
                spreadRadius: .5,
                blurRadius: 8
              )
            ],
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage("assets/wood.png"),
              fit: BoxFit.fill,
            ),
          ),
        ),
        SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.all(6),
                decoration: BoxDecoration(color: Color(0xff202020)),
                child: child,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/topLeft.png"),
                      Image.asset("assets/topRight.png"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/bottomLeft.png"),
                      Image.asset("assets/bottomRight.png"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
