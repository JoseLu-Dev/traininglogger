import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:front_shared/src/core/network/network_info.dart';
import 'package:front_shared/src/core/network/network_info_impl.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([Connectivity])
void main() {
  late MockConnectivity mockConnectivity;
  late NetworkInfo networkInfo;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(mockConnectivity);
  });

  group('NetworkInfoImpl', () {
    group('isConnected', () {
      test('should return true when connected to wifi', () async {
        // arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);

        // act
        final result = await networkInfo.isConnected;

        // assert
        expect(result, true);
        verify(mockConnectivity.checkConnectivity());
      });

      test('should return true when connected to mobile', () async {
        // arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.mobile);

        // act
        final result = await networkInfo.isConnected;

        // assert
        expect(result, true);
        verify(mockConnectivity.checkConnectivity());
      });

      test('should return true when connected to ethernet', () async {
        // arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.ethernet);

        // act
        final result = await networkInfo.isConnected;

        // assert
        expect(result, true);
        verify(mockConnectivity.checkConnectivity());
      });

      test('should return false when not connected', () async {
        // arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.none);

        // act
        final result = await networkInfo.isConnected;

        // assert
        expect(result, false);
        verify(mockConnectivity.checkConnectivity());
      });
    });

    group('connectivityStream', () {
      test('should emit true when connectivity changes to wifi', () async {
        // arrange
        final streamController = Stream<ConnectivityResult>.fromIterable([
          ConnectivityResult.wifi,
        ]);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => streamController);

        // act & assert
        await expectLater(
          networkInfo.connectivityStream,
          emits(true),
        );
      });

      test('should emit true when connectivity changes to mobile', () async {
        // arrange
        final streamController = Stream<ConnectivityResult>.fromIterable([
          ConnectivityResult.mobile,
        ]);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => streamController);

        // act & assert
        await expectLater(
          networkInfo.connectivityStream,
          emits(true),
        );
      });

      test('should emit false when connectivity changes to none', () async {
        // arrange
        final streamController = Stream<ConnectivityResult>.fromIterable([
          ConnectivityResult.none,
        ]);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => streamController);

        // act & assert
        await expectLater(
          networkInfo.connectivityStream,
          emits(false),
        );
      });

      test('should emit multiple values for connectivity changes', () async {
        // arrange
        final streamController = Stream<ConnectivityResult>.fromIterable([
          ConnectivityResult.wifi,
          ConnectivityResult.none,
          ConnectivityResult.mobile,
          ConnectivityResult.none,
        ]);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => streamController);

        // act & assert
        await expectLater(
          networkInfo.connectivityStream,
          emitsInOrder([true, false, true, false]),
        );
      });
    });
  });
}
