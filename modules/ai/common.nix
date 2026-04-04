{
  pkgs,
  inputs,
  config,
}:
let
  lib = pkgs.lib;

  unstablePackages = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };

  llamaCppCuda =
    (unstablePackages.llama-cpp.override {
      cudaSupport = true;
    }).overrideAttrs
      (old: {
        version = "8661";
        src = pkgs.fetchFromGitHub {
          owner = "ggml-org";
          repo = "llama.cpp";
          rev = "b8661";
          hash = "sha256-6PobySuY7jfXyHKyM5cVslcuz2M33vOj5dZ3nbA20RU=";
        };
        postPatch = "";
        cmakeFlags =
          builtins.filter (flag: (builtins.match ".*CMAKE_CUDA_ARCHITECTURES.*" flag) == null) (
            old.cmakeFlags or [ ]
          )
          ++ [ "-DCMAKE_CUDA_ARCHITECTURES=120" ];
      });

  huggingfaceHub = pkgs.python313Packages.huggingface-hub;
  userHome = config.workstation.userHome;
in
{
  inherit huggingfaceHub llamaCppCuda userHome;
  modelsRoot = "${userHome}/models/qwen";

  mkDownloadScript =
    {
      name,
      modelDir,
      repo,
      file,
    }:
    pkgs.writeShellScriptBin name ''
      set -euo pipefail

      mkdir -p "${modelDir}"

      exec ${huggingfaceHub}/bin/hf download \
        ${repo} \
        ${file} \
        --local-dir "${modelDir}"
    '';

  mkUserService =
    {
      description,
      execStart,
      conflicts ? [ ],
      environment ? [ ],
      wantedBy ? [ ],
      wants ? [ ],
      after ? [ ],
      partOf ? [ ],
      restartSec ? 5,
      workingDirectory ? userHome,
    }:
    lib.optionalAttrs (conflicts != [ ]) { inherit conflicts; }
    // lib.optionalAttrs (wantedBy != [ ]) { inherit wantedBy; }
    // lib.optionalAttrs (wants != [ ]) { inherit wants; }
    // lib.optionalAttrs (after != [ ]) { inherit after; }
    // lib.optionalAttrs (partOf != [ ]) { inherit partOf; }
    // {
      inherit description;
      serviceConfig = {
        Environment = environment;
        ExecStart = execStart;
        Restart = "on-failure";
        RestartSec = restartSec;
        WorkingDirectory = workingDirectory;
      };
    };
}
