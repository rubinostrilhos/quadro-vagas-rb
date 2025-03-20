import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["newTags", "btn"]

  connect(){
    this.addTag();
  }

  addTag() {
    const tagIndex = this.newTagsTarget.children.length;
    const newTagContainer = this.tagContainer();
    const newTagField = this.inputAttr(tagIndex);

    newTagContainer.appendChild(newTagField);

    this.newTagsTarget.appendChild(newTagContainer);

    if (tagIndex === 2) {
      this.btnTarget.style.display = "none"; 
    }
  }

  tagContainer(){
    const newTagContainer = document.createElement("div"); 
    newTagContainer.classList.add("mt-2", "mb-2");

    return newTagContainer;
  }

  inputAttr(tagIndex){
    const newTagField = document.createElement("input");
    newTagField.setAttribute("id", `new_tags_fields${tagIndex}`);
    newTagField.setAttribute("type", "text");
    newTagField.setAttribute("name", "job_posting[tag_list][]");
    newTagField.setAttribute("maxlength", "20");
    newTagField.setAttribute("placeholder", "Ruby on Rails");
    newTagField.classList.add("input");

    return newTagField;
  }
}