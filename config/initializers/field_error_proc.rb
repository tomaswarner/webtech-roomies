# Invalid fields are marked with Bootstrap's .is-invalid class (see FormsHelper), so Rails should not wrap them in a div.
ActionView::Base.field_error_proc = proc { |html_tag, _instance| html_tag }
