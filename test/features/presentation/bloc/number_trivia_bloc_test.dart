import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture_with_nullsafty_new/core/error/failure.dart';
import 'package:clean_architecture_with_nullsafty_new/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_with_nullsafty_new/features/number_trivia/domain/usecases/get_conceret_number_trivia.dart';
import 'package:clean_architecture_with_nullsafty_new/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_with_nullsafty_new/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/mocks.mocks.dart';

void main() {
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;
  late NumberTriviaBloc numberTriviaBloc;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    numberTriviaBloc = NumberTriviaBloc(
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test("initial state should be Empty", () {
    // assert
    expect(numberTriviaBloc.state, equals(Empty()));
  });

  group("getTriviaForConcreteNumber", () {
    const tNumberString = "1";
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(text: "test text", number: 1);

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenAnswer((_) => const Right(tNumberParsed));

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "should call InputConverter to validate and convert the string to an unsigned integer",
        build: () {
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => const Right(tNumberTrivia));
          return numberTriviaBloc;
        },
        act: (bloc) =>
            bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
        verify: (_) {
          verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
        });

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "should emit [Error] when the input is invalid",
        build: () {
          when(mockInputConverter.stringToUnsignedInteger(any))
              .thenReturn(Left(InvalidInputFailure()));
          return numberTriviaBloc;
        },
        act: (bloc) =>
            bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
        expect: () => [
              Loading(),
              const Error(message: INVALID_INPUT_FAILURE_MESSAGE),
            ]);

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "should get data from the concrete use case",
        build: () {
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => const Right(tNumberTrivia));
          return numberTriviaBloc;
        },
        act: (bloc) =>
            bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
        verify: (_) {
          verify(
              mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
        });

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "should emit [Loading,Loaded] when data is gotten successfully",
        build: () {
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => const Right(tNumberTrivia));
          return numberTriviaBloc;
        },
        act: (bloc) =>
            bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
        expect: () => [
              Loading(),
              const Loaded(
                trivia: tNumberTrivia,
              ),
            ]);

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "should emit [Loading,Error] when getting data fails",
        build: () {
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Left(ServerFailure()));
          return numberTriviaBloc;
        },
        act: (bloc) =>
            bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
        expect: () => [
              Loading(),
              const Error(message: SERVER_FAILURE_MESSAGE),
            ]);

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should emit [Loading,Error] with a proper message for the error when getting data fails',
        build: () {
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Left(CacheFailure()));
          return numberTriviaBloc;
        },
        act: (bloc) =>
            bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
        expect: () => [
              Loading(),
              const Error(message: CACHE_FAILURE_MESSAGE),
            ]);
  });

  group("getTriviaForRandomNumber", () {
    const tNumberTrivia = NumberTrivia(text: "test text", number: 1);

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "should get data from the random use case",
        build: () {
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => const Right(tNumberTrivia));
          return numberTriviaBloc;
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        verify: (_) {
          verify(mockGetRandomNumberTrivia(NoParams()));
        });

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "should emit [Loading,Loaded] when data is gotten successfully",
        build: () {
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => const Right(tNumberTrivia));
          return numberTriviaBloc;
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        expect: () => [
              Loading(),
              const Loaded(
                trivia: tNumberTrivia,
              ),
            ]);

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "should emit [Loading,Error] when getting data fails",
        build: () {
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => Left(ServerFailure()));
          return numberTriviaBloc;
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        expect: () => [
              Loading(),
              const Error(message: SERVER_FAILURE_MESSAGE),
            ]);

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        'should emit [Loading,Error] with a proper message for the error when getting data fails',
        build: () {
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => Left(CacheFailure()));
          return numberTriviaBloc;
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        expect: () => [
              Loading(),
              const Error(message: CACHE_FAILURE_MESSAGE),
            ]);
  });
}
