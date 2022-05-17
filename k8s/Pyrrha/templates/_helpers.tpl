{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mychart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "apiauth.name" -}}
{{- default .Chart.Name .Values.auth.name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "apimain.name" -}}
{{- default .Chart.Name .Values.main.name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dash.name" -}}
{{- default .Chart.Name .Values.dash.name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "mqttclient.name" -}}
{{- default .Chart.Name .Values.mqttclient.name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "rulesdecision.name" -}}
{{- default .Chart.Name .Values.rulesdecision.name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ws.name" -}}
{{- default .Chart.Name .Values.ws.name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "mqttserver.name" -}}
{{- default .Chart.Name .Values.mqttserver.name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mychart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mychart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "apiauth.labels" -}}
app: {{ include "mychart.name" . }}-{{ .Values.auth.name }}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "apiauth.selectorLabels" . }}
{{- if .Chart.AppVersion }}
version: {{ .Values.auth.image.tag | default .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{- define "apimain.labels" -}}
app: {{ include "mychart.name" . }}-{{ .Values.main.name }}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "apimain.selectorLabels" . }}
{{- if .Chart.AppVersion }}
version: {{ .Values.main.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{- define "dash.labels" -}}
app: {{ include "mychart.name" . }}-{{ .Values.dash.name }}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "dash.selectorLabels" . }}
{{- if .Chart.AppVersion }}
version: {{ .Values.dash.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "mqttclient.labels" -}}
app: {{ include "mychart.name" . }}-{{ .Values.mqttclient.name }}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "mqttclient.selectorLabels" . }}
{{- if .Chart.AppVersion }}
version: {{ .Values.mqttclient.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "rulesdecision.labels" -}}
app: {{ include "mychart.name" . }}-{{ .Values.rulesdecision.name }}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "rulesdecision.selectorLabels" . }}
{{- if .Chart.AppVersion }}
version: {{ .Values.rulesdecision.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "ws.labels" -}}
app: {{ include "mychart.name" . }}-{{ .Values.ws.name }}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "ws.selectorLabels" . }}
{{- if .Chart.AppVersion }}
version: {{ .Values.ws.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "mqttserver.labels" -}}
app: {{ include "mychart.name" . }}-{{ .Values.mqttserver.name }}
helm.sh/chart: {{ include "mychart.chart" . }}
{{ include "mqttserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
version: {{ .Values.mqttserver.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}



{{/*
Selector labels
*/}}
# {{- define "mychart.selectorLabels" -}}
# app.kubernetes.io/name: {{ include "mychart.name" . }}
# app.kubernetes.io/instance: {{ .Release.Name }}
# {{- end }}

{{- define "dash.selectorLabels" -}}
app.kubernetes.io/name:  {{ .Values.dash.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "apimain.selectorLabels" -}}
app.kubernetes.io/name:  {{ .Values.main.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "apiauth.selectorLabels" -}}
app.kubernetes.io/name:  {{ .Values.auth.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "mqttclient.selectorLabels" -}}
app.kubernetes.io/name:  {{ .Values.mqttclient.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "rulesdecision.selectorLabels" -}}
app.kubernetes.io/name:  {{ .Values.rulesdecision.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "ws.selectorLabels" -}}
app.kubernetes.io/name:  {{ .Values.ws.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "mqttserver.selectorLabels" -}}
app.kubernetes.io/name:  {{ .Values.mqttserver.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}