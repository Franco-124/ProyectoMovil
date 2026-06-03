import 'package:supabase_flutter/supabase_flutter.dart';

// Acceso global al cliente — equivalente al object SupabaseClient de Kotlin
SupabaseClient get supabase => Supabase.instance.client;
