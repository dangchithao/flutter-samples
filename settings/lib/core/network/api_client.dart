import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final Duration timeout;

  final http.Client _client;

  ApiClient({
    required this.baseUrl,
    Map<String, String>? headers,
    this.timeout = const Duration(seconds: 30),
    http.Client? client,
  })  : defaultHeaders = headers ?? {},
        _client = client ?? http.Client();

  Future<Either<Failure, T>> request<T>({
    required String path,
    required String method,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(
        queryParameters:
            queryParams?.map((key, value) => MapEntry(key, value.toString())),
      );

      final requestHeaders = {...defaultHeaders, ...?headers};

      late final http.Response response;
      final bodyBytes = body != null ? utf8.encode(jsonEncode(body)) : null;

      switch (method.toUpperCase()) {
        case 'GET':
          response =
              await _client.get(uri, headers: requestHeaders).timeout(timeout);
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: requestHeaders, body: bodyBytes)
              .timeout(timeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: requestHeaders, body: bodyBytes)
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: requestHeaders, body: bodyBytes)
              .timeout(timeout);
          break;
        default:
          throw UnsupportedError('HTTP method $method is not supported');
      }

      final responseBody =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (fromJsonT != null) {
          return Right(fromJsonT(responseBody));
        } else {
          return Right(true as T);
        }
      } else {
        return Left(ServerFailure(
          responseBody['message'] ?? 'An error occurred',
          StackTrace.current,
        ));
      }
    } on SocketException catch (e, stackTrace) {
      return Left(NetworkFailure(e.message, stackTrace));
    } on FormatException catch (e, stackTrace) {
      return Left(ServerFailure('Invalid response format', stackTrace));
    } catch (e, stackTrace) {
      return Left(ServerFailure(e.toString(), stackTrace));
    }
  }

  // Helper methods for common HTTP methods
  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) {
    return request<T>(
      path: path,
      method: 'GET',
      queryParams: queryParams,
      headers: headers,
      fromJsonT: fromJsonT,
    );
  }

  Future<Either<Failure, T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) {
    return request<T>(
      path: path,
      method: 'POST',
      body: body,
      headers: headers,
      fromJsonT: fromJsonT,
    );
  }

  Future<Either<Failure, T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) {
    return request<T>(
      path: path,
      method: 'PUT',
      body: body,
      headers: headers,
      fromJsonT: fromJsonT,
    );
  }

  Future<Either<Failure, T>> delete<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJsonT,
  }) {
    return request<T>(
      path: path,
      method: 'DELETE',
      body: body,
      headers: headers,
      fromJsonT: fromJsonT,
    );
  }

  void close() {
    _client.close();
  }
}
