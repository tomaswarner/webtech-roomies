module FormsHelper
  # Errors for an attribute, including the ones Rails adds to the association (e.g. :neighborhood for :neighborhood_id).
  def errors_for(record, attribute)
    association = attribute.to_s.delete_suffix("_id")
    (record.errors[attribute] + (association == attribute.to_s ? [] : record.errors[association])).uniq
  end

  def field_class(form, attribute, base = "form-control")
    [ base, ("is-invalid" if errors_for(form.object, attribute).any?) ].compact.join(" ")
  end

  def field_errors(form, attribute)
    messages = errors_for(form.object, attribute)
    return if messages.empty?

    tag.div(messages.map(&:upcase_first).to_sentence, class: "invalid-feedback d-block")
  end
end
