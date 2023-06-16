package com.eventsharing.EventSharing.DTO;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class DTOEventResponse {
    private Long id;
    private String title;
    private Double latitude;
    private Double longitude;
    private String address;
    private String date;
    private String tag;
    private String description;
    private String image;
    private String owner;
    private Integer favourites;
    private Integer partecipations;
    private String qrCode;
    private int num_partecipant;
    private int max_partecipnt;
    private String externalLink;

    public DTOEventResponse() {}

    public DTOEventResponse(Long id, String title, Double latitude, Double longitude, String address, LocalDate date, String tag, String description, String image, String owner, Integer favourites, Integer partecipations, String qrCode, int num_partecipant, int max_partecipnt, String externalLink) {
        this.id = id;
        this.title = title;
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        this.date = date.format(df);
        this.tag = tag;
        this.description = description;
        this.image = image;
        this.owner = owner;
        this.favourites = favourites;
        this.partecipations = partecipations;
        this.qrCode = qrCode;
        this.num_partecipant = num_partecipant;
        this.max_partecipnt = max_partecipnt;
        this.externalLink = externalLink;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public String  getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        this.date = date.format(df);
    }
    public String getTag() {
        return tag;
    }

    public void setTag(String tag) {
        this.tag = tag;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getOwner() {
        return owner;
    }

    public void setOwner(String owner) {
        this.owner = owner;
    }

    public Integer getFavourites() {
        return favourites;
    }

    public void setFavourites(Integer favourites) {
        this.favourites = favourites;
    }

    public Integer getPartecipations() {
        return partecipations;
    }

    public void setPartecipations(Integer partecipations) {
        this.partecipations = partecipations;
    }

    public String getQrCode() {
        return qrCode;
    }

    public void setQrCode(String qrCode) {
        this.qrCode = qrCode;
    }

    public int getNumpartecipant() {
        return num_partecipant;
    }

    public void setNumpartecipant(int num_partecipant) {
        this.num_partecipant = num_partecipant;
    }

    public int getMax_partecipnt() {
        return max_partecipnt;
    }

    public void setMax_partecipnt(int max_partecipnt) {
        this.max_partecipnt = max_partecipnt;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getExternalLink() {
        return externalLink;
    }

    public void setExternalLink(String externalLink) {
        this.externalLink = externalLink;
    }

    public int getNum_partecipant() {
        return num_partecipant;
    }

    public void setNum_partecipant(int num_partecipant) {
        this.num_partecipant = num_partecipant;
    }

    @Override
    public String toString() {
        return "DTOEventResponse{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", latitude=" + latitude +
                ", longitude=" + longitude +
                ", date=" + date +
                ", tag='" + tag + '\'' +
                ", description='" + description + '\'' +
                ", owner='" + owner + '\'' +
                ", favourites=" + favourites +
                ", purchased=" + partecipations +
                ", num_partecipant=" + num_partecipant +
                ", max_partecipnt=" + max_partecipnt +
                '}';
    }
}
