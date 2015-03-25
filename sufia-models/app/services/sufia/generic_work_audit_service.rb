module Sufia
  class GenericWorkAuditService
    attr_reader :generic_work
    def initialize(work)
      @generic_work = work
    end

    NO_RUNS = 999

    # provides a human readable version of the audit status
    def human_readable_audit_status
      stat = audit_stat
      case stat
        when 0
          'failing'
        when 1
          'passing'
        else
          stat
      end
    end

    # TODO: What are the appropriate audit behaviors?
    def audit
      []
    end


    private
      def audit_stat
        audit_results = audit.collect { |result| result["pass"] }

        # check how many non runs we had
        non_runs = audit_results.reduce(0) { |sum, value| value == NO_RUNS ? sum += 1 : sum }
        if non_runs == 0
          audit_results.reduce(true) { |sum, value| sum && value }
        elsif non_runs < audit_results.length
          result = audit_results.reduce(true) { |sum, value| value == NO_RUNS ? sum : sum && value }
          "Some audits have not been run, but the ones run were #{result ? 'passing' : 'failing'}."
        else
          'Audits have not yet been run on this file.'
        end
      end

      def needs_audit?(latest_audit)
        return true unless latest_audit
        unless latest_audit.updated_at
          logger.warn "***AUDIT*** problem with audit log! Latest Audit is not nil, but updated_at is not set #{latest_audit}"
          return true
        end
        days_since_last_audit(latest_audit) >= Sufia.config.max_days_between_audits
      end

      def days_since_last_audit(latest_audit)
        (DateTime.now - latest_audit.updated_at.to_date).to_i
      end

  end
end
