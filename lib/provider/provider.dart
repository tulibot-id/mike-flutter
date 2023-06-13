library provider;

import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:appwrite/appwrite.dart' as aw;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tulibot/config/config.dart';
import 'package:tulibot/models/models.dart';
import 'package:tulibot/services/appwrite_service.dart';

part 'locale.dart';
part 'page.dart';
part 'sign.dart';
part 'user.dart';
part 'slider.dart';
