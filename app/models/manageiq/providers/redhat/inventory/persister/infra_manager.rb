class ManageIQ::Providers::Redhat::Inventory::Persister::InfraManager < ManageIQ::Providers::Redhat::Inventory::Persister
  def initialize_inventory_collections
    add_collection(infra, :disks)
    add_collection(infra, :ems_clusters, :secondary_refs => {:by_uid_ems => %i[uid_ems]})
    add_collection(infra, :ems_folders)
    add_collection(infra, :guest_devices)
    add_collection(infra, :hardwares)
    add_collection(infra, :vm_and_template_ems_custom_fields)
    add_collection(infra, :hosts)
    add_collection(infra, :host_guest_devices)
    add_collection(infra, :host_hardwares)
    add_collection(infra, :host_networks)
    add_collection(infra, :host_operating_systems)
    add_collection(infra, :host_storages)
    add_collection(infra, :host_switches)
    add_collection(infra, :host_virtual_switches)
    add_collection(infra, :lans)
    add_collection(infra, :networks)
    add_collection(infra, :operating_systems)
    add_collection(infra, :vms)

    add_datacenters
    add_miq_templates
    add_resource_pools
    add_snapshots
    add_storages

    add_collection(infra, :parent_blue_folders)
    add_collection(infra, :root_folder_relationship)
    add_collection(infra, :vm_resource_pools)
    add_collection(infra, :vm_parent_blue_folders)
  end

  # group :ems_clusters
  def add_resource_pools
    add_collection(infra, :resource_pools) do |builder|
      if targeted?
        builder.add_targeted_arel(
          lambda do |_inventory_collection|
            manager.resource_pools.where(:uid_ems => references(:ems_clusters).collect { |ref| "#{URI(ref).path.split('/').last}_respool" })
          end
        )
      end
    end
  end

  def add_datacenters
    add_collection(infra, :datacenters) do |builder|
      builder.add_properties(:arel => manager.ems_folders.where(:type => 'Datacenter'))

      if targeted?
        builder.add_targeted_arel(
          lambda do |_inventory_collection|
            manager.ems_folders.where(:type => 'Datacenter').where(:ems_ref => references(:datacenters))
          end
        )
      end
    end
  end

  def add_storages
    add_collection(infra, :storages) do |builder|
      if targeted?
        builder.add_targeted_arel(
          lambda do |_inventory_collection|
            ::Storage.where(:ems_ref => references(:storagedomains))
          end
        )
      end
    end
  end

  def add_miq_templates
    add_collection(infra, :miq_templates) do |builder|
      builder.add_properties(:model_class => ::ManageIQ::Providers::Redhat::InfraManager::Template)

      builder.add_properties(:manager_uuids => references(:vms)) if targeted?
    end
  end

  def add_snapshots
    add_collection(infra, :snapshots) do |builder|
      builder.add_properties(
        :manager_ref => %i(uid),
        :strategy    => :local_db_find_missing_references,
      )
    end
  end
end
