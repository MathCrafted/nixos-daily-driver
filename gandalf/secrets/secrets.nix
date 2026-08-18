let
  userMathcrafted = "";
  users = [ userMathcrafted ];

  systemGandalf = "";
  systems = [ systemGandalf ];
in {
  "secretGithub.age".publicKeys = [ userMathcrafted systemGandalf ];
  "secretProxmox.age".publicKeys = [ userMathcrafted ];
}
