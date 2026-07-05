// Mirrors backend/app/features/pet/rules.py.

class Accessory {
  const Accessory({required this.id, required this.emoji, required this.price});

  final String id;
  final String emoji;
  final int price;

  factory Accessory.fromJson(Map<String, dynamic> json) => Accessory(
        id: json['id'] as String,
        emoji: json['emoji'] as String,
        price: json['price'] as int,
      );
}

class PetState {
  const PetState({
    required this.stage,
    required this.mood,
    required this.coins,
    required this.owned,
    required this.equipped,
    required this.catalog,
  });

  final String stage; // egg | chick | bird | phoenix
  final String mood; // happy | ok | sleepy
  final int coins;
  final List<String> owned;
  final List<String> equipped;
  final List<Accessory> catalog;

  String get stageEmoji => switch (stage) {
        'egg' => '🥚',
        'chick' => '🐣',
        'bird' => '🐤',
        _ => '🐥',
      };

  factory PetState.fromJson(Map<String, dynamic> json) => PetState(
        stage: json['stage'] as String,
        mood: json['mood'] as String,
        coins: json['coins'] as int,
        owned: (json['owned'] as List<dynamic>).cast<String>(),
        equipped: (json['equipped'] as List<dynamic>).cast<String>(),
        catalog: (json['catalog'] as List<dynamic>)
            .map((e) => Accessory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
