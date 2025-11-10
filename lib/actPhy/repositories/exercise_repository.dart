import '../models/exercise_model.dart';
import '../services/exercise_service.dart';

class ExerciseRepository {
  final ExerciseService _service = ExerciseService();

  Future<List<Exercise>> getExercises({String bodyPart = '', String equipment = ''}) {
    return _service.fetchExercises(bodyPart: bodyPart, equipment: equipment);
  }
}
