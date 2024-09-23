{{/*
Validate a value must not be empty.
*/}}
{{- define "helpers.validations.values.single.empty" -}}
  {{- $value := include "helpers.utils.getValueFromKey" (dict "key" .valueKey "context" .context) }}
  {{- $subchart := ternary "" (printf "%s." .subchart) (empty .subchart) }}

  {{- if not $value -}}
    {{- $varname := "my-value" -}}
    {{- $getCurrentValue := "" -}}
    {{- if and .secret .field -}}
      {{- $varname = include "helpers.utils.fieldToEnvVar" . -}}
      {{- $getCurrentValue = printf " To get the current value:\n\n        %s\n" (include "helpers.utils.secret.getvalue" .) -}}
    {{- end -}}
    {{- printf "\n    '%s' must not be empty, please add '--set %s%s=$%s' to the command.%s" .valueKey $subchart .valueKey $varname $getCurrentValue -}}
  {{- end -}}
{{- end -}}

{{/*
Validate values must not be empty.
*/}}
{{- define "helpers.validations.values.multiple.empty" -}}
  {{- range .required -}}
    {{- include "helpers.validations.values.single.empty" (dict "valueKey" .valueKey "secret" .secret "field" .field "context" $.context) -}}
  {{- end -}}
{{- end -}}