{{/*
get a secret value.
*/}}
{{- define "helpers.utils.secret.getvalue" -}}
{{- $varname := include "helpers.utils.fieldToEnvVar" . -}}
export {{ $varname }}=$(kubectl get secret --namespace {{ include "helpers.helpers.namespace" .context | quote }} {{ .secret }} -o jsonpath="{.data.{{ .field }}}" | base64 -d)
{{- end -}}

{{/*
Build env var name given a field
*/}}
{{- define "helpers.utils.fieldToEnvVar" -}}
  {{- $fieldNameSplit := splitList "-" .field -}}
  {{- $upperCaseFieldNameSplit := list -}}

  {{- range $fieldNameSplit -}}
    {{- $upperCaseFieldNameSplit = append $upperCaseFieldNameSplit ( upper . ) -}}
  {{- end -}}

  {{ join "_" $upperCaseFieldNameSplit }}
{{- end -}}

{{/*
Gets a value from .Values given
*/}}
{{- define "helpers.utils.getValueFromKey" -}}
{{- $splitKey := splitList "." .key -}}
{{- $value := "" -}}
{{- $latestObj := $.context.Values -}}
{{- range $splitKey -}}
  {{- if not $latestObj -}}
    {{- printf "please review the entire path of '%s' exists in values" $.key | fail -}}
  {{- end -}}
  {{- $value = ( index $latestObj . ) -}}
  {{- $latestObj = $value -}}
{{- end -}}
{{- printf "%v" (default "" $value) -}} 
{{- end -}}

{{/*
Returns first .Values key with a defined value or first of the list if all non-defined
*/}}
{{- define "helpers.utils.getKeyFromList" -}}
{{- $key := first .keys -}}
{{- $reverseKeys := reverse .keys }}
{{- range $reverseKeys }}
  {{- $value := include "helpers.utils.getValueFromKey" (dict "key" . "context" $.context ) }}
  {{- if $value -}}
    {{- $key = . }}
  {{- end -}}
{{- end -}}
{{- printf "%s" $key -}} 
{{- end -}}

{{/*
Checksum a template at "path" containing a *single* resource (ConfigMap,Secret) for use in pod annotations.
*/}}
{{- define "helpers.utils.checksumTemplate" -}}
{{- $obj := include (print .context.Template.BasePath .path) .context | fromYaml -}}
{{ omit $obj "apiVersion" "kind" "metadata" | toYaml | sha256sum }}
{{- end -}}