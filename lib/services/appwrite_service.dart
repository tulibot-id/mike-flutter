import 'dart:io';
// import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as am;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tulibot/config/config.dart';
import 'package:tulibot/models/models.dart';
import 'dart:convert';

class UserAuth {
  static final UserAuth instance = UserAuth._init();
  final Client _client = Client();
  static Account? _account;
  static Avatars? _avatars;

  UserAuth._init();

  Future<Account> get account async {
    if (_account != null) return _account!;

    _account = Account(_client);
    _client.setEndpoint(endPoint).setProject(projectID);
    return _account!;
  }

  Future<Avatars> get avatar async {
    if (_avatars != null) return _avatars!;

    _avatars = Avatars(_client);
    _client.setEndpoint(endPoint).setProject(projectID);
    return _avatars!;
  }


  Future<bool> login(String email, String password) async {
    final account = await instance.account;
    try {
      await account.createEmailSession(email: email, password: password);
      return true;
    } on AppwriteException catch (e) {
      print('loginError: ${e.message}');
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    final account = await instance.account;
    try {
      await account.create(
          userId: 'unique()', name: name, email: email, password: password);
      return true;
    } on AppwriteException catch (_) {
      return false;
    }
  }

  Future verification() async {
    final account = await instance.account;
    try {
      await account.createVerification(url: endPointVerify);
    } on AppwriteException catch (e) {
      throw Exception('verificationError: ${e.message}');
    }
  }

  Future confirmVerification(String userId, String secret) async {
    final account = await instance.account;
    try {
      await account.updateVerification(userId: userId, secret: secret);
    } on AppwriteException catch (e) {
      throw Exception('confirmVerificationError: ${e.message}');
    }
  }

  Future resetPassword(String email) async {
    final account = await instance.account;
    try {
      final token =
          await account.createRecovery(email: email, url: endPointReset);
      return token;
    } on AppwriteException catch (e) {
      throw Exception('resetPassword: ${e.message}');
    }
  }

  Future confirmResetPassword(String userId, String secret, String password,
      String passwordAgain) async {
    final account = await instance.account;
    try {
      await account.updateRecovery(
          userId: userId,
          secret: secret,
          password: password,
          passwordAgain: passwordAgain);
    } on AppwriteException catch (e) {
      throw Exception('confirmResetPasswordError: ${e.message}');
    }
  }

  Future<bool> loginWithGoogle() async {
    final account = await instance.account;
    try {
      await account.createOAuth2Session(provider: 'google');
      return true;
    } on AppwriteException catch (_) {
      return false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> loginWithMicrosoft() async {
    final account = await instance.account;
    try {
      await account.createOAuth2Session(provider: 'microsoft');
      return true;
    } on AppwriteException catch (_) {
      return false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future logout() async {
    final account = await instance.account;
    try {
      await account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw Exception('logoutError: ${e.message}');
    }
  }

  Future<am.Account> get getAccount async {
    final account = await instance.account;
    return await account.get();
  }

  Future updateName(String name) async {
    final account = await instance.account;
    try {
      await account.updateName(name: name);
    } on AppwriteException catch (e) {
      throw Exception('updateNameError: ${e.message}');
    }
  }

  // Future deleteAccount() async {
  //   final account = await instance.account;
  //   try {
  //     await account.delete();
  //   } on AppwriteException catch (e) {
  //     throw Exception('deleteAccountError: ${e.message}');
  //   }
  // }

  Future getPreferences() async {
    final account = await instance.account;
    try {
      final preferences = await account.getPrefs();
      return preferences.data;
    } catch (_) {
      return null;
    }
  }

  Future getUserID() async {
    final account = await instance.account;
    try {
      final preferences = await account.get();
      return preferences.$id;
    } catch (_) {
      return null;
    }
  }

  Future getUserName() async {
    final account = await instance.account;
    try {
      final preferences = await account.get();
      return preferences.name;
    } catch (_) {
      return null;
    }
  }


  Future getUserEmail() async {
    final account = await instance.account;
    try {
      final preferences = await account.get();
      return preferences.email;
    } catch (_) {
      return null;
    }
  }

  Future updatePreferences(Map<String, dynamic> json) async {
    final account = await instance.account;
    try {
      await account.updatePrefs(prefs: json);
    } on AppwriteException catch (e) {
      throw Exception('updatePreferencesError: ${e.message}');
    }
  }

  Future<Uint8List?> getUserInitialProfile(String name) async {
    final avatar = await instance.avatar;
    try {
      final result = await avatar.getInitials(name: name);
      return result;
    } catch (_) {
      return null;
    }
  }
}

class RealTimeAccount {
  static final RealTimeAccount instance = RealTimeAccount._init();
  final Client _client = Client();
  static Realtime? _realtime;

  RealTimeAccount._init();

  Future<Realtime> get realtime async {
    if (_realtime != null) return _realtime!;

    _realtime = Realtime(_client);
    _client.setEndpoint(endPoint).setProject(projectID);
    return _realtime!;
  }

  Future<RealtimeSubscription> subsribe(List<String> channel) async {
    final realtime = await instance.realtime;
    return realtime.subscribe(channel);
  }
}
