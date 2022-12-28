# Add Supplemental Learning Center Workshops

After you've completed installing Tanzu Application Platform you may wish to author and add workshops to one or more Learning Center training portals.

Consult the [public documentation](https://docs.vmware.com/en/Tanzu-Application-Platform/1.4/tap/GUID-learning-center-workshop-content-about.html) for how to author and publish your own workshops.

We provide a few additional workshops that you may easily install by visiting the `gitops/tanzu/learningcenter/supplemental` [directory](../../gitops/tanzu/learningcenter/supplemental), then executing:

```
cd gitops/tanzu/learningcenter/supplemental
kapp deploy --app lcs --file .init --yes
kubectl apply -f .install
```

To check in on available Training Portals

```
kubectl get trainingportal -A
```
> Visit the URL of a training portal in your favorite browser to view and start a workshop on-demand.

To view the available Workshops

```
kubectl get workshops -A
```

To uninstall

```cd gitops/tanzu/learningcenter/supplemental
kubectl delete -f .install
kapp delete --app lcs --yes
```
