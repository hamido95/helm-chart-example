{{/*
Create secret name.
*/}}
{{- define "helpers.secrets.name" -}}
{{- $name := (include "helpers.helpers.fullname" .context) -}}

{{- if .defaultNameSuffix -}}
{{- $name = printf "%s-%s" $name .defaultNameSuffix | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- with .existingSecret -}}
{{- if not (typeIs "string" .) -}}
{{- with .name -}}
{{- $name = . -}}
{{- end -}}
{{- else -}}
{{- $name = . -}}
{{- end -}}
{{- end -}}

{{- printf "%s" $name -}}
{{- end -}}

{{/*
Create secret key.
*/}}
{{- define "helpers.secrets.key" -}}
{{- $key := .key -}}

{{- if .existingSecret -}}
  {{- if not (typeIs "string" .existingSecret) -}}
    {{- if .existingSecret.keyMapping -}}
      {{- $key = index .existingSecret.keyMapping $.key -}}
    {{- end -}}
  {{- end }}
{{- end -}}

{{- printf "%s" $key -}}
{{- end -}}

{{/*
Create secret password or retrieve one if created before.
*/}}
{{- define "helpers.secrets.passwords.manage" -}}

{{- $password := "" }}
{{- $subchart := "" }}
{{- $chartName := default "" .chartName }}
{{- $passwordLength := default 10 .length }}
{{- $providedPasswordKey := include "common.utils.getKeyFromList" (dict "keys" .providedValues "context" $.context) }}
{{- $providedPasswordValue := include "common.utils.getValueFromKey" (dict "key" $providedPasswordKey "context" $.context) }}
{{- $secretData := (lookup "v1" "Secret" (include "helpers.helpers.namespace" .context) .secret).data }}
{{- if $secretData }}
  {{- if hasKey $secretData .key }}
    {{- $password = index $secretData .key | b64dec }}
  {{- else if not (eq .failOnNew false) }}
    {{- printf "\nPASSWORDS ERROR: The secret \"%s\" does not contain the key \"%s\"\n" .secret .key | fail -}}
  {{- end -}}
{{- end }}

{{- if not $password }}
  {{- if $providedPasswordValue }}
    {{- $password = $providedPasswordValue | toString }}
  {{- else }}
    {{- if .context.Values.enabled }}
      {{- $subchart = $chartName }}
    {{- end -}}

    {{- if not (eq .failOnNew false) }}
      {{- $requiredPassword := dict "valueKey" $providedPasswordKey "secret" .secret "field" .key "subchart" $subchart "context" $.context -}}
      {{- $requiredPasswordError := include "helpers.validations.values.single.empty" $requiredPassword -}}
      {{- $passwordValidationErrors := list $requiredPasswordError -}}
      {{- include "helpers.errors.upgrade.passwords.empty" (dict "validationErrors" $passwordValidationErrors "context" $.context) -}}
    {{- end }}

    {{- if .strong }}
      {{- $subStr := list (lower (randAlpha 1)) (randNumeric 1) (upper (randAlpha 1)) | join "_" }}
      {{- $password = randAscii $passwordLength }}
      {{- $password = regexReplaceAllLiteral "\\W" $password "@" | substr 5 $passwordLength }}
      {{- $password = printf "%s%s" $subStr $password | toString | shuffle }}
    {{- else }}
      {{- $password = randAlphaNum $passwordLength }}
    {{- end }}
  {{- end -}}
{{- end -}}
{{- if not .skipB64enc }}
{{- $password = $password | b64enc }}
{{- end -}}
{{- if .skipQuote -}}
{{- printf "%s" $password -}}
{{- else -}}
{{- printf "%s" $password | quote -}}
{{- end -}}
{{- end -}}

{{/*
Reuses the value from an existing secret, otherwise sets its value to a default value.
*/}}
{{- define "helpers.secrets.lookup" -}}
{{- $value := "" -}}
{{- $secretData := (lookup "v1" "Secret" (include "helpers.helpers.namespace" .context) .secret).data -}}
{{- if and $secretData (hasKey $secretData .key) -}}
  {{- $value = index $secretData .key -}}
{{- else if .defaultValue -}}
  {{- $value = .defaultValue | toString | b64enc -}}
{{- end -}}
{{- if $value -}}
{{- printf "%s" $value -}}
{{- end -}}
{{- end -}}

{{/*
Returns whether a previous generated secret already exists
*/}}
{{- define "helpers.secrets.exists" -}}
{{- $secret := (lookup "v1" "Secret" (include "helpers.helpers.namespace" .context) .secret) }}
{{- if $secret }}
  {{- true -}}
{{- end -}}
{{- end -}}