# CloudWatch Container Insights

Ejecutar `bash scripts/cloudwatch.sh` una vez creado EKS. El script consulta la versión compatible en AWS y no crea roles. LabRole debe tener los permisos necesarios para publicar métricas y logs (CloudWatchAgentServerPolicy o equivalentes). Si hay AccessDenied o DEGRADED, registrar el error y consultar al profesor; no modificar IAM sin autorización.

En CloudWatch, región us-east-1: Container Insights > devops-ev3, CPU/memoria por nodo y pod; Logs > Log groups > /aws/containerinsights/devops-ev3/application. Revisar también performance. Guardar capturas reales. Para limitar costos, configurar retención corta (p. ej. 1 día) si el Lab lo permite y eliminar los grupos específicos al finalizar, después de guardar evidencia. No confundir logs con métricas de la malla.
