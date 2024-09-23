{{/*
image name
*/}}
{{- define "apim.image" -}}
{{ include "helpers.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
service account name to use
 */}}
{{- define "apim.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "helpers.helpers.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Image Registry Secret Names
*/}}
{{- define "apim.imagePullSecrets" -}}
{{ include "helpers.images.renderPullSecrets" (dict "images" (list .Values.image ) "context" $) }}
{{- end -}}


{{/*
Return the proper Prometheus metrics image name
*/}}
{{- define "nginx.metrics.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) }}
{{- end -}}