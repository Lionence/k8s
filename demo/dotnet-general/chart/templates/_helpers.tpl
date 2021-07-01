{{- define "appName" -}}
{{- $_ := required ".Values.APP_NAME is mandatory!" .Values.APP_NAME -}}
{{- default .Values.APP_NAME -}}
{{- end -}}

{{- define "dockerImage" -}}
{{- $_ := required ".Values.image.repo is mandatory!" .Values.image.repo -}}
{{- $_ := required ".Values.image.name is mandatory!" .Values.image.name -}}
{{- $_ := required ".Values.image.tag is mandatory!" .Values.image.tag -}}
{{ printf "%s/%s:%s" .Values.image.repo .Values.image.name .Values.image.tag }}
{{- end -}}

{{- define "namespace" -}}
{{- $_ := required ".Values.TARGET_NAMESPACE is mandatory!" .Values.TARGET_NAMESPACE -}}
{{- default .Values.TARGET_NAMESPACE -}}
{{- end -}}