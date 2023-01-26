import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenmode/blocs/auth_bloc/auth_bloc.dart';
import 'package:zenmode/screens/auth/auth_screen.dart';
import 'package:zenmode/services/main_service.dart';

// TODO: сделать обертку для всего, что связано с Supabase.

class MainMockService extends Mock implements MainService {}

class SupabaseMockClient extends Mock implements SupabaseClient {}

class GoTrueMockClient extends Mock implements GoTrueClient {}

void main() {
  Widget createAuthScreen() {
    return BlocProvider(
      create: (context) => AuthBloc(
        mainService: MainMockService(),
        client: SupabaseMockClient(),
      ),
      child: const AuthScreen(),
    );
  }

  testWidgets(
    'title visible',
    (WidgetTester tester) async {
      await tester.pumpWidget(createAuthScreen());

      expect(
        find.text('Sign in'),
        findsOneWidget,
      );

      // Build our app and trigger a frame.
      // await tester.pumpWidget(const MyApp());

      // Verify that our counter starts at 0.
      // expect(find.text('0'), findsOneWidget);
      // expect(find.text('1'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      // await tester.tap(find.byIcon(Icons.add));
      // await tester.pump();

      // Verify that our counter has incremented.
      // expect(find.text('0'), findsNothing);
      // expect(find.text('1'), findsOneWidget);
    },
  );
}
