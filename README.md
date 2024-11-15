# CryptoCurrenciesList is an application for tracking the exchange rate of cryptocurrencies, having only two screens, a list of cryptocurrencies, a cryptocurrency with detailed information

Technologies: 
- Basic architecture 
- splitting screens into features
- firebase
- DI (GetIt)
- flutter_bloc
- dio
- tallker for logging
- auto_router


![All screens](https://github.com/BUYZQ/CryptoCurrenciesList/blob/main/ASSETS_README/all_screens.png)

# Project structure

![Structure](https://github.com/BUYZQ/CryptoCurrenciesList/blob/main/ASSETS_README/project_structure.png)

# Features app

The application has two features that contain view, block and widgets

![Features](https://github.com/BUYZQ/CryptoCurrenciesList/blob/main/ASSETS_README/features.png)

# Crypto List UI

This screen displays a list of cryptocurrencies with their current exchange rates. It uses a Bloc to handle state and fetch the list from a repository.

```dart @RoutePage()
class CryptoListScreen extends StatefulWidget {
  const CryptoListScreen({super.key});

  @override
  State<CryptoListScreen> createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  final _cryptoListBloc = CryptoListBloc(GetIt.I<AbstractCoinsRepository>());

  @override
  void initState() {
    _cryptoListBloc.add(LoadCryptoList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CryptoCurrenciesList'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TalkerScreen(talker: GetIt.I<Talker>()),
                ),
              );
            },
            icon: const Icon(Icons.document_scanner_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final completer = Completer();
          _cryptoListBloc.add(LoadCryptoList(completer: completer));
          return completer.future;
        },
        child: BlocBuilder<CryptoListBloc, CryptoListState>(
          bloc: _cryptoListBloc,
          builder: (context, state) {
            if (state is CryptoListLoaded) {
              return ListView.separated(
                itemCount: state.coinsList.length,
                separatorBuilder: (context, index) =>
                    Divider(color: theme.dividerColor),
                itemBuilder: (context, index) {
                  final coin = state.coinsList[index];
                  return CryptoCoinTile(coin: coin);
                },
              );
            }
            if (state is CryptoListLoadingFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Something went wrong',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'Please try againg later',
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    TextButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primaryColor,
                      ),
                      onPressed: () {
                        _cryptoListBloc.add(LoadCryptoList());
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            );
          },
        ),
      ),
    );
  }
}
```

CryptoListScreen: Displays the list of cryptocurrencies.
Bloc: Fetches data on initialization and triggers a refresh when the user pulls down on the list.

# Crypto List Logic

This is the Bloc that handles loading the list of cryptocurrencies from the repository and manages different states (loading, loaded, failure).

``` dart class CryptoListBloc extends Bloc<CryptoListEvent, CryptoListState> {
  CryptoListBloc(this._abstractCoinsRepository) : super(CryptoListInitial()) {
    on<LoadCryptoList>((event, emit) async {
      try {
        if(state is! CryptoListLoaded) {
          emit(CryptoListLoading());
        }
        final coinsList = await _abstractCoinsRepository.getCoinsList();
        emit(CryptoListLoaded(coinsList: coinsList));
      } catch(e, st) {
        emit(CryptoListLoadingFailure(exception: e));
        GetIt.I<Talker>().handle(e, st);
      } finally {
        event.completer?.complete();
      }
    });
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    GetIt.I<Talker>().handle(error, stackTrace);
  }

  final AbstractCoinsRepository _abstractCoinsRepository;
} 
```

CryptoListBloc: Handles the logic for loading the cryptocurrency list, including error handling and state updates.

# Crypto coin UI

This screen displays detailed information about a specific cryptocurrency. It listens to changes in the CryptoCoinDetailsBloc to show data like price and 24-hour high/low.

```dart @RoutePage()
class CryptoCoinScreen extends StatefulWidget {
  const CryptoCoinScreen({required this.coin, super.key});
  final CryptoCoin coin;

  @override
  State<CryptoCoinScreen> createState() => _CryptoCoinScreenState();
}

class _CryptoCoinScreenState extends State<CryptoCoinScreen> {

  final _cryptoDetailsBloc = CryptoCoinDetailsBloc(GetIt.I<AbstractCoinsRepository>());

  @override
  void initState() {
    super.initState();
    _cryptoDetailsBloc.add(LoadCryptoCoinDetails(currencyCode: widget.coin.name));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<CryptoCoinDetailsBloc, CryptoCoinDetailsState>(
        bloc: _cryptoDetailsBloc,
        builder: (context, state) {
          if (state is CryptoCoinDetailsLoaded) {
            final coin = state.coin;
            final coinDetails = coin.details;
            return Center(
              child: Column(
                children: [
                  Image.network(coinDetails.fullImageUrl, width: 200),
                  Text(
                    coin.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  BaseCard(
                    child: Text(
                      coinDetails.priceInUSD.toStringAsFixed(4),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  BaseCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'High 24 Hour',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(coinDetails.high24Hour.toStringAsFixed(4)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Low 24 Hour'),
                            Text(coinDetails.low24Hour.toStringAsFixed(4)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is CryptoCoinLoadingDetailsFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Something went wrong',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    'Please try againg later',
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

CryptoCoinScreen: Displays details for a specific cryptocurrency.
Bloc: Handles the loading of cryptocurrency details and shows the data.

# Crypto Coin Logic

This Bloc fetches the details for a specific cryptocurrency based on its name and updates the state accordingly.

```dart 
class CryptoCoinDetailsBloc
    extends Bloc<CryptoCoinDetailsEvent, CryptoCoinDetailsState> {
  CryptoCoinDetailsBloc(this.coinsRepository)
      : super(CryptoCoinDetailsInitial()) {
    on<LoadCryptoCoinDetails>(_load);
  }

  Future<void> _load(
    LoadCryptoCoinDetails event,
    Emitter<CryptoCoinDetailsState> emit,
  ) async {
    try {
      if(state is! CryptoCoinDetailsLoaded) {
        emit(CryptoCoinDetailsLoading());
      }
      final coinDetails = await coinsRepository.getCoinDetails(event.currencyCode);
      emit(CryptoCoinDetailsLoaded(coin: coinDetails));
    } catch(e, st) {
      emit(CryptoCoinLoadingDetailsFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    GetIt.I<Talker>().handle(error, stackTrace);
  }

  final AbstractCoinsRepository coinsRepository;
}
```
CryptoCoinDetailsBloc: Handles loading of detailed information for a selected cryptocurrency.

# Crypto Coins Repository

CryptoCoinsRepository constructor: Initializes the repository with a Dio instance for API requests and a Hive Box for local data storage.

getCoinsList method: Fetches a list of cryptocurrency data:

- Attempts to retrieve the list from an API using _fetchCoinsListFromApi.
- Saves the data to the Hive box (cryptoCoinsBox) for offline use.
- If the API call fails, retrieves data from the Hive box instead.
- Sorts the list of cryptocurrencies by their price in USD in descending order and returns it.

_fetchCoinsListFromApi method: Makes an API call to fetch cryptocurrency data. Parses the API response and converts it into a list of CryptoCoin objects.

getCoinDetails method: Fetches details of a specific cryptocurrency:

- Tries to fetch the details from the API using _fetchCoinDetailsFromApi.
- Saves the fetched data to the Hive box for offline use.
- If the API call fails, retrieves the cryptocurrency details from the Hive box.

_fetchCoinDetailsFromApi method: Fetches detailed information about a single cryptocurrency from the API and returns it as a CryptoCoin object.

``` dart class CryptoCoinsRepository implements AbstractCoinsRepository {
  CryptoCoinsRepository({
    required this.dio,
    required this.cryptoCoinsBox,
  });

  final Dio dio;
  final Box<CryptoCoin> cryptoCoinsBox;

  @override
  Future<List<CryptoCoin>> getCoinsList() async {
    var cryptoCoinsList = <CryptoCoin>[];
    try {
      cryptoCoinsList = await _fetchCoinsListFromApi();
      final cryptoCoinsMap = {
        for (var e in cryptoCoinsList) e.name: e,
      };
      await cryptoCoinsBox.putAll(cryptoCoinsMap);
    } catch (e, st) {
      GetIt.I<Talker>().handle(e, st);
      cryptoCoinsList = cryptoCoinsBox.values.toList();
    }
    cryptoCoinsList.sort((a, b) => b.details.priceInUSD.compareTo(a.details.priceInUSD));
    return cryptoCoinsList;
  }

  Future<List<CryptoCoin>> _fetchCoinsListFromApi() async {
    final response = await dio.get(
        'https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC,ETH,BNB,TON,NOT,DOGS&tsyms=USD');
    final data = response.data as Map<String, dynamic>;
    final dataRaw = data['RAW'] as Map<String, dynamic>;
    final cryptoCoinsList = dataRaw.entries.map((e) {
      final usdData =
          (e.value as Map<String, dynamic>)['USD'] as Map<String, dynamic>;
      final details = CryptoCoinDetails.fromJson(usdData);
      return CryptoCoin(
        name: e.key,
        details: details,
      );
    }).toList();
    return cryptoCoinsList;
  }

  @override
  Future<CryptoCoin> getCoinDetails(String currencyCode) async {
    try {
      final coin = await _fetchCoinDetailsFromApi(currencyCode);
      cryptoCoinsBox.put(currencyCode, coin);
      return coin;
    } catch(e, st) {
      GetIt.I<Talker>().handle(e, st);
      return cryptoCoinsBox.get(currencyCode)!;
    }
  }

  Future<CryptoCoin> _fetchCoinDetailsFromApi(String currencyCode) async {
     final response = await dio.get(
        'https://min-api.cryptocompare.com/data/pricemultifull?fsyms=$currencyCode&tsyms=USD');

    final data = response.data as Map<String, dynamic>;
    final dataRaw = data['RAW'] as Map<String, dynamic>;
    final coinData = dataRaw[currencyCode] as Map<String, dynamic>;
    final usdData = coinData['USD'] as Map<String, dynamic>;
    final details = CryptoCoinDetails.fromJson(usdData);

    return CryptoCoin(
      name: currencyCode,
      details: details,
    );
  }
}
```

# Routes

AppRouter class: Configures navigation routes for the application using the auto_route package.
Defines two routes:
1 / - The main route displaying the list of cryptocurrencies (CryptoListRoute).
2 A route for detailed cryptocurrency information (CryptoCoinRoute).


```dart @AutoRouterConfig()
class AppRouter extends RootStackRouter {

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: CryptoListRoute.page, path: '/'),
    AutoRoute(page: CryptoCoinRoute.page)
  ];
}
```

# main.dart

Initialization: Sets up essential components before the app runs.

WidgetsFlutterBinding.ensureInitialized: Ensures Flutter bindings are initialized for asynchronous operations.

Talker: Initializes a logging utility to monitor and log app activity and errors.

Hive: Sets up local storage:

Registers adapters for CryptoCoin and CryptoCoinDetails.

Opens a Hive box for storing cryptocurrency data.

Firebase: Initializes Firebase for backend services and logs the Firebase project ID.

Dio: Configures the HTTP client with an interceptor (TalkerDioLogger) for logging API request and response activity.

Bloc.observer: Sets up a global observer to monitor state changes and events in the app using the Bloc package.

GetIt: Registers dependencies such as AbstractCoinsRepository and Talker for dependency injection.

FlutterError.onError: Handles uncaught Flutter framework errors by logging them with Talker.

runApp: Starts the app by launching the CryptoCurrenciesListApp widget.


```dart void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final talker = TalkerFlutter.init();
  GetIt.I.registerSingleton(talker);
  GetIt.I<Talker>().debug('Talker started...');

  const cryptoCoinsBoxName = 'crypto_coins_box';

  await Hive.initFlutter();

  Hive.registerAdapter(CryptoCoinAdapter());
  Hive.registerAdapter(CryptoCoinDetailsAdapter());

  final cryptoCoinsBox = await Hive.openBox<CryptoCoin>(cryptoCoinsBoxName);

  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  talker.info(app.options.projectId);

  final dio = Dio();
  dio.interceptors.add(
    TalkerDioLogger(
      talker: talker,
      settings: const TalkerDioLoggerSettings(
        printResponseData: false,
      ),
    ),
  );

  Bloc.observer = TalkerBlocObserver(
    talker: talker,
    settings: const TalkerBlocLoggerSettings(
      printEventFullData: false,
      printStateFullData: false,
    ),
  );

  GetIt.I.registerLazySingleton<AbstractCoinsRepository>(
    () => CryptoCoinsRepository(
      dio: dio,
      cryptoCoinsBox: cryptoCoinsBox,
    ),
  );
  FlutterError.onError =
      (details) => GetIt.I<Talker>().handle(details.exception, details.stack);

  runApp(const CryptoCurrenciesListApp());
}
```