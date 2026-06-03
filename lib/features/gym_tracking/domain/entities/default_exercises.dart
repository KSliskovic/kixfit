import 'exercise.dart';

final List<Exercise> defaultExercises = [
  // Prsa (Chest)
  Exercise(id: 'bench_press_barbell', name: 'Potisak šipkom s ravne klupe (Bench Press)', muscleGroup: 'Prsa', equipment: 'Barbell'),
  Exercise(id: 'bench_press_dumbbell', name: 'Potisak bučicama s ravne klupe', muscleGroup: 'Prsa', equipment: 'Dumbbell'),
  Exercise(id: 'incline_bench_press_barbell', name: 'Potisak šipkom s kose klupe', muscleGroup: 'Prsa', equipment: 'Barbell'),
  Exercise(id: 'incline_bench_press_dumbbell', name: 'Potisak bučicama s kose klupe', muscleGroup: 'Prsa', equipment: 'Dumbbell'),
  Exercise(id: 'chest_fly_dumbbell', name: 'Razvlačenje bučicama na ravnoj klupi', muscleGroup: 'Prsa', equipment: 'Dumbbell'),
  Exercise(id: 'push_up', name: 'Sklekovi', muscleGroup: 'Prsa', equipment: 'Bodyweight'),
  
  // Leđa (Back)
  Exercise(id: 'pull_up', name: 'Zgibovi (Pull-up)', muscleGroup: 'Leđa', equipment: 'Bodyweight'),
  Exercise(id: 'lat_pulldown', name: 'Povlačenje na lat mašini', muscleGroup: 'Leđa', equipment: 'Cable'),
  Exercise(id: 'barbell_row', name: 'Veslanje u pretklonu šipkom', muscleGroup: 'Leđa', equipment: 'Barbell'),
  Exercise(id: 'dumbbell_row', name: 'Jednoručno veslanje bučicom', muscleGroup: 'Leđa', equipment: 'Dumbbell'),
  Exercise(id: 'deadlift_barbell', name: 'Mrtvo dizanje šipkom', muscleGroup: 'Leđa', equipment: 'Barbell'),
  
  // Ramena (Shoulders)
  Exercise(id: 'overhead_press_barbell', name: 'Vojnički potisak šipkom (OHP)', muscleGroup: 'Ramena', equipment: 'Barbell'),
  Exercise(id: 'overhead_press_dumbbell', name: 'Potisak bučicama iznad glave', muscleGroup: 'Ramena', equipment: 'Dumbbell'),
  Exercise(id: 'lateral_raise_dumbbell', name: 'Bočno letenje bučicama', muscleGroup: 'Ramena', equipment: 'Dumbbell'),
  Exercise(id: 'front_raise_dumbbell', name: 'Prednje letenje bučicama', muscleGroup: 'Ramena', equipment: 'Dumbbell'),
  Exercise(id: 'rear_delt_fly_dumbbell', name: 'Letenje bučicama u pretklonu (stražnje rame)', muscleGroup: 'Ramena', equipment: 'Dumbbell'),
  
  // Noge (Legs)
  Exercise(id: 'squat_barbell', name: 'Stražnji čučanj šipkom', muscleGroup: 'Noge', equipment: 'Barbell'),
  Exercise(id: 'leg_press', name: 'Potisak na leg press mašini', muscleGroup: 'Noge', equipment: 'Machine'),
  Exercise(id: 'leg_extension', name: 'Ekstenzija nogu (šut)', muscleGroup: 'Noge', equipment: 'Machine'),
  Exercise(id: 'leg_curl', name: 'Fleksija nogu (zadnja loža)', muscleGroup: 'Noge', equipment: 'Machine'),
  Exercise(id: 'romanian_deadlift_barbell', name: 'Rumunjsko mrtvo dizanje šipkom', muscleGroup: 'Noge', equipment: 'Barbell'),
  Exercise(id: 'calf_raise', name: 'Podizanje na prste za listove', muscleGroup: 'Noge', equipment: 'Bodyweight'),
  
  // Ruke (Arms - Biceps/Triceps)
  Exercise(id: 'bicep_curl_barbell', name: 'Pregib šipkom za biceps', muscleGroup: 'Ruke', equipment: 'Barbell'),
  Exercise(id: 'bicep_curl_dumbbell', name: 'Pregib bučicama za biceps', muscleGroup: 'Ruke', equipment: 'Dumbbell'),
  Exercise(id: 'hammer_curl_dumbbell', name: 'Hammer pregib bučicama', muscleGroup: 'Ruke', equipment: 'Dumbbell'),
  Exercise(id: 'tricep_pushdown_cable', name: 'Opružanje tricepsa na sajli', muscleGroup: 'Ruke', equipment: 'Cable'),
  Exercise(id: 'skull_crusher_barbell', name: 'Skull Crusher šipkom', muscleGroup: 'Ruke', equipment: 'Barbell'),
  Exercise(id: 'dip_chest', name: 'Propadanja (Dips)', muscleGroup: 'Ruke', equipment: 'Bodyweight'),
  
  // Trbuh (Abs)
  Exercise(id: 'crunch', name: 'Trbušnjaci (Crunches)', muscleGroup: 'Trbuh', equipment: 'Bodyweight'),
  Exercise(id: 'hanging_leg_raise', name: 'Viseće podizanje nogu', muscleGroup: 'Trbuh', equipment: 'Bodyweight'),
  Exercise(id: 'plank', name: 'Plank', muscleGroup: 'Trbuh', equipment: 'Bodyweight'),
];
