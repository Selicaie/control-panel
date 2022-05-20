import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Artboard1 extends StatelessWidget {
  Artboard1({
    Key ?key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Stack(
        children: <Widget>[
          Pinned.fromPins(
            Pin(start: 10.0, end: 10.0),
            Pin(start: 42.0, end: 42.0),
            child: SvgPicture.string(
              _svg_ry3ejf,
              allowDrawingOutsideViewBox: true,
              fit: BoxFit.fill,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 58.0, middle: 0.5),
            Pin(size: 235.5, end: 65.0),
            child: Stack(
              children: <Widget>[
                Pinned.fromPins(
                  Pin(size: 1.0, middle: 0.5175),
                  Pin(size: 142.0, start: 0.0),
                  child: SvgPicture.string(
                    _svg_tfrvb,
                    allowDrawingOutsideViewBox: true,
                    fit: BoxFit.fill,
                  ),
                ),
                Pinned.fromPins(
                  Pin(start: 0.0, end: 0.0),
                  Pin(size: 58.0, end: 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                      color: const Color(0xffffffff),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const String _svg_tfrvb =
    '<svg viewBox="250.5 199.5 1.0 142.0" ><path transform="translate(250.5, 199.5)" d="M 0 0 L 0 142" fill="none" stroke="#ffffff" stroke-width="46" stroke-miterlimit="4" stroke-linecap="round" /></svg>';
const String _svg_ry3ejf =
    '<svg viewBox="10.0 42.0 480.0 416.0" ><path transform="translate(10.0, 42.0)" d="M 227.0072021484375 22.52082252502441 C 232.7796325683594 12.51527214050293 247.2203369140625 12.51527118682861 252.9927673339844 22.52082061767578 L 467.0216369628906 393.504150390625 C 472.7908935546875 403.5041809082031 465.5737609863281 416 454.0288696289062 416 L 25.97115135192871 416 C 14.4262809753418 416 7.209136009216309 403.5041809082031 12.97836685180664 393.504150390625 Z" fill="#ff1a1a" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
