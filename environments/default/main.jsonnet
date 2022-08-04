local aiven = import "github.com/jsonnet-libs/aiven-libsonnet/0.3.0/main.libsonnet";

{
  config:: {
    aivenSecretName: "aiven-token",
    aivenSecretKey: "token",
    connInfoSecretTarget: "os-token",
    project: "ankorstore-application-services-playground",
    cloudname: "google-europe-west1",
    plan: "startup-4",
    maintenanceWindowDow: "friday",
    maintenanceWindowTime: "23:00:00",
    name: "os-sample-rem",
    number_of_replicas: 1,
    number_of_shards: 1,
    dashboard: "enabled"
  },

  local os = aiven.aiven.v1alpha1.openSearch,

  opensearch: {
    local this = self,

    service+:: 
    os.new(name='%(name)s' % $.config.name)
    + os.spec.authSecretRef.withName($.config.aivenSecretName)
    + os.spec.authSecretRef.withKey($.config.aivenSecretKey)
    + os.spec.connInfoSecretTarget.withName($.config.connInfoSecretTarget)
    + os.spec.withProject($.config.project)
    + os.spec.withCloudName($.config.cloudname)
    + os.spec.withPlan($.config.plan)
    + os.spec.withMaintenanceWindowDow($.config.maintenanceWindowDow)
    + os.spec.withMaintenanceWindowTime($.config.maintenanceWindowTime),

    local osCfg = os.spec.userConfig,

    userConfig+::
      osCfg.index_template.withNumber_of_replicas($.config.number_of_replicas)
      + osCfg.index_template.withNumber_of_shards($.config.number_of_shards)
      + osCfg.opensearch_dashboards($.config.dashboard)
      + os.metadata.withAnnotationsMixin(this.service),

    myOpensearch:
      this.service,
  },
}
