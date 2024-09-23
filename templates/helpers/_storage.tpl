{{/*
Create the Storage Class
*/}}
{{- define "helpers.storage.class" -}}
{{- $storageClass := (.global).storageClass | default .persistence.storageClass | default "" -}}
{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else -}}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}
{{- end -}}