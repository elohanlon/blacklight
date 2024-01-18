import CheckboxSubmit from './checkbox_submit.js'

const BookmarkToggle = (e) => {
  if (e.target.matches('[data-checkboxsubmit-target="checkbox"]')) {
    const form = e.target.closest('form')
    if (form) new CheckboxSubmit(form).clicked(e);
  }
};

document.addEventListener('click', BookmarkToggle);

export default BookmarkToggle
