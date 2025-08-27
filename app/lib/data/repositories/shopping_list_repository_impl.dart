import '../../domain/repositories/shopping_list_repository.dart';
import '../datasources/remote/remote_shopping_list_datasource.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  final RemoteShoppingListDataSource remoteDataSource;
  ShoppingListRepositoryImpl({required this.remoteDataSource});
}