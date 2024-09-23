{{/*
Print error when using empty passwords values that must not be empty.
*/}}
{{- define "helpers.errors.upgrade.passwords.empty" -}}
  {{- $validationErrors := join "" .validationErrors -}}
  {{- if and $validationErrors .context.Release.IsUpgrade -}}
    {{- $errorString := "\nPASSWORDS ERROR: You must provide your current passwords when upgrading the release." -}}
    {{- $errorString = print $errorString "\n%s" -}}
    {{- printf $errorString $validationErrors | fail -}}
  {{- end -}}
{{- end -}}