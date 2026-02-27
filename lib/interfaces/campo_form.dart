abstract class CampoForm {
  /// retorna o valor do campo em String (para salvar)
  String get valorString;

  /// atualiza o valor do campo via String
  void setValorString(String v);

  /// valida o conteúdo do campo
  bool validar();

  /// coloca foco no campo
  void focus();
}
