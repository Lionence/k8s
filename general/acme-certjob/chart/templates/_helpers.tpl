{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kubeconfig" -}}
{{- echo .Values.kubeconfig | b64enc -}}
{{- end -}}