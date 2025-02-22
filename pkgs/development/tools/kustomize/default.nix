{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "kustomize";
  version = "4.5.3";
  # rev is the commit of the tag, mainly for kustomize version command output
  rev = "b2d65ddc98e09187a8e38adc27c30bab078c1dbf";

  ldflags = let t = "sigs.k8s.io/kustomize/api/provenance"; in
    [
      "-s"
      "-X ${t}.version=${version}"
      "-X ${t}.gitCommit=${rev}"
    ];

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = pname;
    rev = "kustomize/v${version}";
    sha256 = "sha256-sy429uTTYvjnweZlsuolBamcggRXmaR8uxD043GUIQE=";
  };

  doCheck = true;

  # avoid finding test and development commands
  sourceRoot = "source/kustomize";

  vendorSha256 = "sha256-5kMMSr+YyuoASgW+qzkyO4CcDHFFANcsAZTUqHX5nGk=";

  meta = with lib; {
    description = "Customization of kubernetes YAML configurations";
    longDescription = ''
      kustomize lets you customize raw, template-free YAML files for
      multiple purposes, leaving the original YAML untouched and usable
      as is.
    '';
    homepage = "https://github.com/kubernetes-sigs/kustomize";
    license = licenses.asl20;
    maintainers = with maintainers; [ carlosdagos vdemeester periklis zaninime Chili-Man saschagrunert ];
  };
}
