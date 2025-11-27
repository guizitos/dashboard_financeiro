import 'package:flutter/material.dart';

class CategoryVisual {
  final IconData icon;
  final Color color;
  const CategoryVisual(this.icon, this.color);
}

CategoryVisual getCategoryVisual(String rawName, ColorScheme scheme) {
  final name = rawName.toLowerCase();
  
  // Receitas
  if (name == 'salário' || name == 'salario') {
    return CategoryVisual(Icons.attach_money_rounded, scheme.primary);
  } else if (name.contains('freelance')) {
    return CategoryVisual(Icons.computer_rounded, Colors.blue);
  } else if (name.contains('invest')) {
    return CategoryVisual(Icons.trending_up_rounded, Colors.green);
  } else if (name.contains('venda')) {
    return CategoryVisual(Icons.point_of_sale_rounded, Colors.amber);
  } else if (name.contains('bonifica') || name.contains('bônus') || name.contains('bonus')) {
    return CategoryVisual(Icons.card_giftcard_rounded, Colors.purple);
  } else if (name.contains('aluguel') && !name.contains('despesa')) {
    return CategoryVisual(Icons.apartment_rounded, Colors.teal);
  }
  
  // Despesas
  else if (name.contains('aliment')) {
    return CategoryVisual(Icons.restaurant_rounded, Colors.orange);
  } else if (name.contains('transp')) {
    return CategoryVisual(Icons.directions_car_rounded, Colors.blueGrey);
  } else if (name.contains('moradia') || name.contains('casa') || (name.contains('aluguel') && name.contains('despesa'))) {
    return CategoryVisual(Icons.home_rounded, Colors.brown);
  } else if (name.contains('saúde') || name.contains('saude')) {
    return CategoryVisual(Icons.medical_services_rounded, Colors.redAccent);
  } else if (name.contains('educa')) {
    return CategoryVisual(Icons.school_rounded, Colors.indigo);
  } else if (name.contains('lazer') || name.contains('entretenimento')) {
    return CategoryVisual(Icons.sports_esports_rounded, Colors.purple);
  } else if (name.contains('compra') || name.contains('shopping')) {
    return CategoryVisual(Icons.shopping_cart_rounded, Colors.pinkAccent);
  } else if (name.contains('conta') || name.contains('fatura')) {
    return CategoryVisual(Icons.receipt_long_rounded, Colors.deepOrange);
  } else if (name.contains('streaming') || name.contains('assinatura')) {
    return CategoryVisual(Icons.play_circle_outline_rounded, Colors.red);
  } else if (name.contains('academia') || name.contains('fitness') || name.contains('gym')) {
    return CategoryVisual(Icons.fitness_center_rounded, Colors.orange);
  } else if (name.contains('pet') || name.contains('animal')) {
    return CategoryVisual(Icons.pets_rounded, Colors.brown);
  } else if (name.contains('vestuário') || name.contains('roupa') || name.contains('vestuario')) {
    return CategoryVisual(Icons.checkroom_rounded, Colors.pink);
  } else if (name.contains('viagem') || name.contains('turismo')) {
    return CategoryVisual(Icons.flight_rounded, Colors.cyan);
  } else if (name.contains('presente') || name.contains('gift')) {
    return CategoryVisual(Icons.card_giftcard_rounded, Colors.deepPurple);
  } else if (name.contains('outro')) {
    return CategoryVisual(Icons.more_horiz_rounded, scheme.secondary);
  }
  
  // Default
  return CategoryVisual(Icons.label_rounded, scheme.secondary);
}
