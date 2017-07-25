require 'spec_helper'

module Bosh::Director
  describe Errand::LifecycleErrandStep do
    subject(:errand_step) do
      Errand::LifecycleErrandStep.new(
        runner,
        deployment_planner,
        errand_name,
        instance,
        instance_group,
        changes_exist,
        keep_alive,
        deployment_name,
        logger
      )
    end

    let(:deployment_planner) { instance_double(DeploymentPlan::Planner, job_renderer: job_renderer) }
    let(:runner) { instance_double(Errand::Runner) }
    let(:instance_group) { instance_double(DeploymentPlan::InstanceGroup, is_errand?: is_errand) }
    let(:errand_name) { 'errand_name' }
    let(:changes_exist) { false }
    let(:job_renderer) { instance_double(JobRenderer) }
    let(:deployment_name) { 'deployment-name' }
    let(:errand_result) { Errand::Result.new(exit_code, nil, nil, nil) }
    let(:instance) { instance_double(DeploymentPlan::Instance) }
    let(:keep_alive) { 'maybe' }

    describe '#run' do
      before do
        expect(job_renderer).to receive(:clean_cache!)
      end

      context 'when instance group is lifecycle errand' do
        let(:is_errand) { true }
        let(:exit_code) { 0 }

        let(:instance_group_manager) { instance_double(Errand::InstanceGroupManager) }
        let(:errand_instance_updater) { instance_double(Errand::ErrandInstanceUpdater) }

        it 'creates the vm, then runs the errand' do
          expect(Errand::InstanceGroupManager).to receive(:new).with(deployment_planner, instance_group, logger).and_return(instance_group_manager)
          expect(Errand::ErrandInstanceUpdater).to receive(:new)
               .with(instance_group_manager, logger, errand_name, deployment_name)
               .and_return(errand_instance_updater)
          expect(errand_instance_updater).to receive(:with_updated_instances).with(instance_group, keep_alive) do |&blk|
            blk.call
          end
          expect(runner).to receive(:run).and_return(errand_result)
          result = errand_step.run(&lambda {})
          expect(result).to eq("Errand 'errand_name' completed successfully (exit code 0)")
        end
      end
    end
  end
end