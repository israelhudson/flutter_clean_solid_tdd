import 'dart:io';

import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter_clean_solid_tdd/domain/helpers/helpers.dart';
import 'package:flutter_clean_solid_tdd/domain/usecases/usecases.dart';

import 'package:flutter_clean_solid_tdd/data/http/http.dart';
import 'package:flutter_clean_solid_tdd/data/usecases/usecases.dart';

class HttpClientSpy extends Mock implements HttpClient{}

void main(){
  HttpClientSpy httpClient;
  String url;
  RemoteAuthentication sut;

  setUp((){
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
  });

  test('Should call HttpClient with correct values', () async {
    final params = AuthenticationParams(email: faker.internet.email(), secret: faker.internet.password());
    await sut.auth(params);

    verify(httpClient.request(
      url: url,
      method: 'post',
      body: {'email': params.email, 'password': params.secret}
      ));
  });

  test('Should throw UnexpectedError of HttpClient returns 400', () async {
    when(httpClient.request(url: anyNamed('url'), method: anyNamed('method'), body: anyNamed('body')))
      .thenThrow(HttpError.badRequest);

    final params = AuthenticationParams(email: faker.internet.email(), secret: faker.internet.password());
    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
}