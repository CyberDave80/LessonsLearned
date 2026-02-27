{\rtf1\ansi\ansicpg1252\cocoartf2867
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 Menlo-Regular;}
{\colortbl;\red255\green255\blue255;\red255\green255\blue255;\red194\green125\blue100;}
{\*\expandedcolortbl;;\cssrgb\c100000\c100000\c100000;\cssrgb\c80772\c56796\c46790;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\partightenfactor0

\f0\fs24 \cf0 \cb2 \expnd0\expndtw0\kerning0
# Troubleshooting Knative when services resolve to internal cluster DNS instead of a public URL\
\
**Description:** Steps to fix Knative services resolving to internal IPs instead of publicly accessible URLs.\
\
1. **Check Knative service status**  \
`kubectl get ksvc -n default <your-service-name>`  \
- Problem: URL shows internal DNS (`.svc.cluster.local`) instead of external.\
\
2. **Check external IP of Kourier ingress**  \
`kubectl get svc kourier -n knative-serving`  \
- Look for `EXTERNAL-IP`, e.g., `52.224.150.61`.\
\
3. **Check domain configuration**  \
`kubectl get cm config-domain -n knative-serving -o yaml`  \
- If `data` only has `_example`, the default-domain job failed or didn\'92t run.\
\
4. **Check default-domain job status**  \
`kubectl get job default-domain -n knative-serving`  \
- If `STATUS: Complete` but old \uc0\u8594  job ran before LoadBalancer IP was ready.\
\
5. **Check job logs**  \
`kubectl logs -n knative-serving -l app=default-domain --tail=10`\
\
6. **Fix domain issue**  \
- Delete and let it recreate:  \
  `kubectl delete job default-domain -n knative-serving`  \
- If not auto-recreated \uc0\u8594  reapply job YAML or manually edit ConfigMap:  \
  `kubectl edit cm config-domain -n knative-serving`  \
- Add under `data:`:  \
  ``<external-ip>.sslip.io: ""``  \
\
7. **Verify updated service URL**  \
`kubectl get ksvc -n default <your-service-name>`  \
- Should now show: `http://<your-service-name>.default.<external-ip>.sslip.io`\
}