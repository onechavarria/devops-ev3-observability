"""Validación estática del proyecto y políticas mínimas del laboratorio."""
from pathlib import Path
import sys
import yaml

ROOT = Path(__file__).resolve().parents[1]


def validate():
    errors = []
    for directory in ("infrastructure", "kubernetes", "istio", "monitoring"):
        for path in (ROOT / directory).rglob("*.yaml"):
            try:
                documents = list(yaml.safe_load_all(path.read_text(encoding="utf-8")))
                for doc in filter(None, documents):
                    if not all(key in doc for key in ("apiVersion", "kind", "metadata")) and doc.get("kind") != "IstioOperator":
                        errors.append(f"{path.name}: manifiesto incompleto")
                    if doc.get("kind") == "Secret":
                        errors.append(f"{path.name}: Secret no permitido en Git")
                    if doc.get("kind") == "Deployment":
                        for container in doc["spec"]["template"]["spec"]["containers"]:
                            image = container["image"]
                            if image.endswith(":latest") or (":" not in image.rsplit("/", 1)[-1] and "@sha256:" not in image):
                                errors.append(f"{path.name}: imagen sin versión {image}")
            except (yaml.YAMLError, KeyError, TypeError) as exc:
                errors.append(f"{path.name}: {exc}")
    config = yaml.safe_load((ROOT / "infrastructure/eks-cluster.yaml").read_text())
    if config["iam"]["serviceRoleARN"] != "__LAB_ROLE_ARN__" or config["iam"]["withOIDC"]:
        errors.append("Debe reutilizarse LabRole sin crear OIDC")
    for group in config["managedNodeGroups"]:
        if group["iam"]["instanceRoleARN"] != "__LAB_ROLE_ARN__":
            errors.append("Nodo sin LabRole")
    namespace = yaml.safe_load((ROOT / "kubernetes/namespace.yaml").read_text())
    if namespace["metadata"]["labels"].get("istio-injection") != "enabled":
        errors.append("Inyección deshabilitada")
    lb = yaml.safe_load((ROOT / "monitoring/kiali/kiali-lb.yaml").read_text())
    if lb["spec"]["type"] != "LoadBalancer" or lb["metadata"]["annotations"].get("service.beta.kubernetes.io/aws-load-balancer-internal") != "true":
        errors.append("Kiali debe tener LB interno")
    return errors


if __name__ == "__main__":
    issues = validate()
    for issue in issues:
        print(issue, file=sys.stderr)
    print(f"Validación: {len(issues)} errores")
    sys.exit(bool(issues))
