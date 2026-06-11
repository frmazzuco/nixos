# Fonte unica de verdade para as portas dos servidores de modelos locais.
# e4b e 26b compartilham a porta de proposito: os grupos de conflito do
# systemd (Conflicts=) garantem que apenas um deles roda por vez.
{
  "qwen35-9b" = 8080;
  "gemma4-e4b" = 18083;
  "gemma4-26b" = 18083;
  "gemma4-31b" = 8084;
}
