part of 'crypto_coin_details_bloc.dart';

abstract class CryptoCoinDetailsEvent {}

class LoadCryptoCoinDetails extends CryptoCoinDetailsEvent {
  LoadCryptoCoinDetails({required this.currencyCode});

  final String currencyCode;
}