package com.eventsharing.EventSharing.model;

import jakarta.persistence.*;

import java.time.LocalDate;
import java.util.Set;

@Entity
@Table(name = "events")
public class Event {

    @Id
    @SequenceGenerator(
            name = "event_sequence",
            sequenceName = "event_sequence",
            allocationSize = 1
    )

    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "event_sequence"
    )

    private Long id;
    private String title;
    private Double latitude;
    private Double longitude;
    private String address;
    private LocalDate date;
    private String tag;
    private String externalLink;
    @Column(
        length = 1000
    )
    private String description;
    @Lob
    private String image;
    @ManyToOne
    @JoinColumn(name = "owner_id")
    private User owner;
    private String qrCode;
    private int num_partecipant;
    private int max_partecipnt;

    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL)
    private Set<Partecipation> partecipations;

    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL)
    private Set<Favourite> favourites;

    public Event() {
    }

    public Event(String title, Double latitude, Double longitude, String address, LocalDate date, String tag, String description, String image, User owner, String externalLink, Integer max_partecipnt) {
        this.title = title;
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        this.date = date;
        this.tag = tag;
        this.description = description;
        this.image = image;
        this.owner = owner;
        this.max_partecipnt = max_partecipnt;
        this.externalLink = externalLink;
    }

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public Double getLatitude() {
        return latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public LocalDate getDate() {
        return date;
    }

    public String getTag() {
        return tag;
    }

    public String getDescription() {
        return description;
    }

    public String getImage() {
        return image;
    }

    public User getOwner() {
        return owner;
    }

    public String getQrCode() {
        return qrCode;
    }

    public int getNum_partecipant() {
        return num_partecipant;
    }

    public int getMax_partecipnt() {
        return max_partecipnt;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public void setTag(String tag) {
        this.tag = tag;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public void setOwner(User owner) {
        this.owner = owner;
    }

    public void setQrCode(String qrCode) {
        this.qrCode = qrCode;
    }

    public void setNum_partecipant(int num_partecipant) {
        this.num_partecipant = num_partecipant;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public void setMax_partecipnt(int max_partecipnt) {
        this.max_partecipnt = max_partecipnt;
    }

    public String getExternalLink() {
        return externalLink;
    }

    public void setExternalLink(String externalLink) {
        this.externalLink = externalLink;
    }

    public Set<Partecipation> getPartecipations() {
        return partecipations;
    }

    public void setPartecipations(Set<Partecipation> partecipations) {
        this.partecipations = partecipations;
    }

    public Set<Favourite> getFavourites() {
        return favourites;
    }

    public void setFavourites(Set<Favourite> favourites) {
        this.favourites = favourites;
    }

    @Override
    public String toString() {
        return "Event{" +
                "title='" + title + '\'' +
                ", latitude=" + latitude +
                ", longitude=" + longitude +
                ", date=" + date +
                ", tag='" + tag + '\'' +
                ", description='" + description + '\'' +
                ", owner=" + owner +
                ", externalLink=" + externalLink +
                ", maxPartecipant=" + max_partecipnt +
                '}';
    }
}

