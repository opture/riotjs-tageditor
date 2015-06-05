<insignia-tag-description-with-references>
    <div each={tag, i in tags}>
        <h1 if={i==1}>References</h1>
        <insignia-tag-description tag={tag}></insignia-tag-description>
    </div>
    this.tags = opts.tags;
</insignia-tag-description-with-references>